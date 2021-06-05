module EasyPayULatam
  class PayUPaymentMailer < ApplicationMailer

    def success(name, email, payment)
      @name = name
      @payment = payment
      mail to: email, subject: "¡Hemos recibido tu pago!"
    end

    def error(name, email, payment)
      @name = name
      @payment = payment
      mail to: email, subject: "¡Tu pago ha sido rechazado!"
    end

  end
end
