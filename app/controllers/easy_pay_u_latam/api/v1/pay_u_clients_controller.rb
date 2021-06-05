module EasyPayULatam
  class Api::V1::PayUClientsController < ApiController

    acts_as_token_authentication_handler_for User

    def create
      client = RApi::Client.new current_user.pay_u_costumer_id
      is_new = false
      if client.response.nil?
        is_new = true
        client.params = { 'fullName' => current_user.name, 'email' => current_user.email }
        res = client.create!
        current_user.update_attribute :pay_u_costumer_id, res["id"]
      end
      render status: 200, json: {is_new: is_new}
    end
  end
end
