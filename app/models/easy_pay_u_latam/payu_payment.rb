module EasyPayULatam
  class PayuPayment < ApplicationRecord
    PENDING = 0
    APPROVED = 1
    REJECTED = 2

    validates :amount, :currency, :user_id, :description, presence: true

    def approved
      self.status == APPORVED
    end

    def rejected
      self.status == REJECTED
    end

    def pending
      self.status == PENDING
    end

    def add_charge(params)
      @payUConfig = EasyPayULatam.configuration

      client = RApi::Client.new current_user.pay_u_costumer_id
      addcharge = RApi::AdditionalCharge.new client, self.reference_recurring_payment
      addcharge.params = {
        "description": params[:description],
        "additionalValues": {
          {
            "name": "ITEM_VALUE",
            "value": params[:value],
            "currency": "COP"
          },
          {
            "name": "ITEM_TAX",
            "value": "0",
            "currency": "COP"
          },
          {
            "name": "ITEM_TAX_RETURN_BASE",
            "value": "0",
            "currency": "COP"
          }
        }
      }

      addcharge.create!

      addcharge
    end

    def remove_charge(id)
      @payUConfig = EasyPayULatam.configuration

      client = RApi::Client.new current_user.pay_u_costumer_id
      addcharge = RApi::AdditionalCharge.new client, self.reference_recurring_payment

      addcharge.delete id

      addcharge
    end

  end
end
