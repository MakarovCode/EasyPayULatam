module EasyPayULatam
  class Api::V1::PayUPaymentsController < ApiController

    #  acts_as_token_authentication_handler_for User

    def index
      @payu_payments = PayuPayment.where(user_id: current_user.id)
    end

    def show
      @payu_payment = PayuPayment.where(user_id: current_user.id).find params[:id]
    end

    def get_status
      payu_payment = PayuPayment.where(user_id: current_user.id).order(created_at: :desc).first

      message = "Tu pago está "
      if payu_payment.status == PayuPayment::APPROVED
        message += "Aprobado"
      elsif payu_payment.status == PayuPayment::REJECTED
        message += "Rechazado"
      else
        message += "Pendiente"
      end

      render status: 200, json: {message: message, payment_status: payu_payment.status}
    end

    def confirmation
      @payUConfig = EasyPayULatam.configuration
      # Generacion de codigo en md5
      md5 = Digest::MD5.new
      #             api-key      ~  merchant_id      ~      id-sale              ~      valor       ~      cop       ~aprovada
      md5.update "#{@payUConfig.get_api_key}~#{@payUConfig.get_merchant_id}~#{params['reference_sale']}~#{params['value'].to_f}~#{params['currency']}~4"
      key = md5.hexdigest

      if key.to_s == params['sign'].to_s
        payu_payment = PayuPayment.find(params[:id])
        unless payu_payment.nil?

          status = 2
          if params['state_pol'] == "4"
            status = 1
          end

          payu_payment.update(
            status: status,
            buyer_phone: params['phone'],
            number_card: params['cc_number'],
            payer_name: params['cc_holder'],
            billing_country: params['billing_country'],
            description: params['description'],
            # value: params['value'],
            payment_method_type: params['payment_method_type'],
            buyer_email: params['email_buyer'],
            response_message_pol: params['response_message_pol'],
            shipping_city: params['shipping_city'],
            transaction_id: params['transaction_id'],
            sign: params['sign'],
            tax: params['tax'],
            payment_method: params['payment_method'],
            billing_address: params['billing_address'],
            payment_method_name: params['payment_method_name'],
            state_pol: params['state_pol'],
            buyer_nickname: params['nickname_buyer'],
            reference_pol: params['reference_pol'],
            currency: params['currency'],
            risk: params['risk'],
            shipping_address: params['shipping_address'],
            bank_id: params['bank_id'],
            payment_request_state: params['payment_request_state'],
            customer_number: params['customer_number'],
            administrative_fee_base: params['administrative_fee_base'],
            attempts: params['attempts'],
            merchant_id: params['merchant_id'],
            exchange_rate: params['exchange_rate'],
            shipping_country: params['shipping_country'],
            franchise: params['franchise'],
            ip: params['ip'],
            billing_city: params['billing_city'],
            reference_code: params['reference_sale']
          )

          if params['state_pol'] == "4"
            PayUPaymentMailer.success(payu_payment.payer_name, payu_payment.buyer_email, payu_payment).deliver_now!
          else
            PayUPaymentMailer.error(payu_payment.payer_name, payu_payment.buyer_email, payu_payment).deliver_now!
          end

          render status: 200, json: { status: 'OK', message: 'OK', params: params }

        else
          PayUPaymentMailer.error(payu_payment.payer_name, payu_payment.email_buyer, payu_payment).deliver_now!
          render status: 200, json: { status: 'OK', message: 'No existe referencia de pago', params: params }
        end
      else

        render status: 200, json: { status: 'OK', message: 'Error de seguridad signature', params: params }
      end

    end

  end

  private

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = %w{GET POST OPTIONS HEAD}.join(',')
  end
end
