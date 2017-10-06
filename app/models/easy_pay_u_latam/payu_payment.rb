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

  end
end
