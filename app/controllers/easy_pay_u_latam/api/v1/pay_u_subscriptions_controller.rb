module EasyPayULatam
  class Api::V1::PayUSubscriptionsController < ApiController

    acts_as_token_authentication_handler_for User

    def index
      client = RApi::Client.new current_user.pay_u_costumer_id
      subs = RApi::Subscription.new client
      
      unless subs.response["recurringBillList"].blank?
        render status: 200, json: {subscriptions: current_user.all_payments.first(30), subscriptions_api: subs.response["recurringBillList"].last(30)}
      else
        render status: 200, json: {subscriptions: [], subscriptions_api: []}
      end
    end

    def create
      @payUConfig = EasyPayULatam.configuration
      generate_payment(params[:subscription][:plan][:planCode])

      client = RApi::Client.new current_user.pay_u_costumer_id
      subs = RApi::Subscription.new client
      subs.params = params[:subscription].as_json
      subs.params["customer"]["id"] = current_user.pay_u_costumer_id
      subs.params["customer"]["creditCards"][0]["token"] = current_user.payu_default_card

      if !current_user.last_payment.nil? && current_user.last_payment.end_date > Date.today
        subs.params["trialDays"] = (current_user.last_payment.end_date - Date.today).to_i
      elsif current_user.last_payment.nil?
        subs.params["trialDays"] = @plan.trial_days.blank? ? 0 : @plan.trial_days
      end

      subs.params["notifyUrl"] = "#{@payUConfig.get_root_url}/easy_pay_u_latam/api/v1/pay_u_payments/#{ @payu_payment.id}/confirmation.json?user_id=#{current_user.id}"

      response = subs.create!

      unless subs.response.blank?
        render status: 200, json: {message: "ok"}
      else
        msg = subs.error["errorList"].blank? ? subs.error["description"] : subs.error["errorList"].to_sentence
        render status: 411, json: {message: msg }
      end
    end

    def update
      # client = RApi::Client.new current_user.pay_u_costumer_id
      # current_user.update_attribute :payu_default_card, params[:id]
      # #validat si tiene subscripciones y actualizar subscricion
      render status: 200, json: {message: "ok, done nothing"}
    end

    def destroy
      client = RApi::Client.new current_user.pay_u_costumer_id
      subs = RApi::Subscription.new client

      if current_user.last_payments.count > 0
        current_user.last_payments.each do |sub|
          res = subs.delete sub.reference_recurring_payment
          sub.update_attribute :response_message_pol, "CANCELLED BY USER"
          sub.update_attribute :state_pol, "-1"
        end

        render status: 200, json: {message: "¡Subscripción cancelada correctamente, tu plan estará activo por el periodo que ya habías pagado!"}
      else
        render status: 411, json: {message: "No tienes subscripciones para cancelar"}
      end

    end

    def generate_payment(plan_code)
      plan = Plan.actives.find_by_payu_plan_code plan_code
      @plan = plan
      # period_moths = 1 if plan.interval.downcase == "day"
      period_moths = 1 if plan.interval.downcase == "month"
      period_moths = 6 if plan.interval.downcase == "semester"
      period_moths = 12 if plan.interval.downcase == "year"

      current_user.update_attribute(:temp_plan_id, plan.id)

      period = "del día" if plan.interval.downcase == "day"
      period = "del año" if plan.interval.downcase == "year"
      period = "del semestre" if plan.interval.downcase == "semester"
      period = "del mes" if plan.interval.downcase == "month"

      # end_date = Date.today + 1.day if plan.interval.downcase == "day"
      end_date = Date.today + 1.month if plan.interval.downcase == "month"
      end_date = Date.today + 6.months if plan.interval.downcase == "semester"
      end_date = Date.today + 1.year if plan.interval.downcase == "year"

      @payu_payment = EasyPayULatam::PayuPayment.create(
        # amount: plan["value_month"],
        amount: plan["value_#{plan.interval.downcase}"],
        currency: "COP",
        period: period_moths,
        plan_id: plan.id,
        user_id: current_user.id,
        description: "Pago #{plan.name} #{period} UPICK",
        start_date: Date.today,
        end_date: end_date
      )
    end
  end
end
