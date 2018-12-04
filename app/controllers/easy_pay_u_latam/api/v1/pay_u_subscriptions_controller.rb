module EasyPayULatam
  class Api::V1::PayUSubscriptionsController < ApiController

    acts_as_token_authentication_handler_for User

    def index
      client = RApi::Client.new current_user.pay_u_costumer_id
      subs = RApi::Subscription.new client

      unless subs.response["recurringBillList"].blank?
        render status: 200, json: {subscriptions: subs.response["recurringBillList"].last(30)}
      else
        render status: 200, json: {subscriptions: []}
      end
    end

    def create
      client = RApi::Client.new current_user.pay_u_costumer_id
      subs = RApi::Subscription.new client
      subs.params = params[:subscription].as_json
      subs.params["customer"]["id"] = current_user.pay_u_costumer_id
      subs.params["customer"]["creditCards"][0]["token"] = current_user.payu_default_card
      response = subs.create!
      binding.pry
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
      unless subs.response.blank?
        unless subs.response["creditCardList"].empty?
          res = subs.delete params[:id]

          render status: 200, json: {message: res["description"]}
        else
          render status: 411, json: {message: "No tienes subscripciones para cancelar"}
        end
      else
        render status: 411, json: {message: "No tienes subscripciones para cancelar"}
      end
    end
  end
end
