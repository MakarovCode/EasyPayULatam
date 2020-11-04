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

    def add_charge(params, user)
      @payUConfig = EasyPayULatam.configuration

      client = RApi::Client.new user.pay_u_costumer_id
      addcharge = RApi::AdditionalCharge.new client, self.reference_recurring_payment
      addcharge.params = {
        "description" => params[:description],
        "additionalValues" => [
          {
            "name" => "ITEM_VALUE",
            "value" => params[:value],
            "currency" => "COP"
          },
          {
            "name" => "ITEM_TAX",
            "value" => "0",
            "currency" => "COP"
          },
          {
            "name" => "ITEM_TAX_RETURN_BASE",
            "value" => "0",
            "currency" => "COP"
          }
        ]
      }

      res = addcharge.create!

      unless res["id"].blank?
        self.additional_charges_data = "#{self.additional_charges_data}|#{res["id"]}·#{Date.today}"
      end

      addcharge
    end

    def get_additional_charges
      charges = []
      self.additional_charges_data.split("|").each do |charge|
        data = charge.split("·")
        charges.push({id: data[0], date: data[1]})
      end
      charges
    end

    def remove_charge(id, user)
      @payUConfig = EasyPayULatam.configuration

      client = RApi::Client.new user.pay_u_costumer_id
      addcharge = RApi::AdditionalCharge.new client, self.reference_recurring_payment

      addcharge.delete id

      addcharge
    end

  end
end
