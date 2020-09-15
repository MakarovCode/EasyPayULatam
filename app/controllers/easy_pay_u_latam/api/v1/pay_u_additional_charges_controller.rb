module EasyPayULatam
  class Api::V1::PayUAdditionalChargesController < ApiController

    acts_as_token_authentication_handler_for User

    def create

      addcharge = current_user.last_payment.add_charge(params)

      unless addcharge.response.blank?
        render status: 200, json: {message: "ok"}
      else
        msg = addcharge.error["errorList"].blank? ? addcharge.error["description"] : addcharge.error["errorList"].to_sentence
        render status: 411, json: {message: msg }
      end
    end

    def destroy
  
      if current_user.last_payments.count > 0
        current_user.last_payment.remove_charge(params[:charge_id])

        render status: 200, json: {message: "¡Cargo extra cancelado correctamente, tu plan estará activo por el periodo que ya habías pagado!"}
      else
        render status: 411, json: {message: "No tienes cargos extra para cancelar"}
      end

    end
  end
end
