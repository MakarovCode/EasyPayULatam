module EasyPayULatam
  class PayUPaymentsController < ApplicationController

    # before_action :authenticate_user!

    def index
      @payu_payments = PayuPayment.where(user_id: params[:user_id])
    end

    def show
      @payu_payment = PayuPayment.where(user_id: params[:user_id]).find params[:id]
    end

    def edit
      @payUConfig = EasyPayULatam.configuration
      @payu_payment = PayuPayment.where(user_id: params[:user_id]).find params[:id]

      @payu_payment.update_attribute :reference_code, "#{@payUConfig.placeholder}-#{@payu_payment.id}"
      @payu_payment.update_attribute :status, PayuPayment::PENDING

      md5 = Digest::MD5.new
      md5.update "#{@payUConfig.get_api_key}~#{@payUConfig.get_merchant_id}~#{@payUConfig.placeholder}-#{@payu_payment.id}~#{@payu_payment.amount}~#{@payu_payment.currency}"
      @signature = md5.hexdigest
    end

  end
end
