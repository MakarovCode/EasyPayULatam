module EasyPayULatam
  class Api::V1::PayUCardsController < ApiController

    acts_as_token_authentication_handler_for User

    def index
      client = RApi::Client.new current_user.pay_u_costumer_id
      cards = RApi::Card.new client
      unless cards.response["creditCardList"].blank?
        render status: 200, json: {cards: cards.response["creditCardList"]}
      else
        render status: 200, json: {cards: []}
      end
    end

    def destroy
      client = RApi::Client.new current_user.pay_u_costumer_id
      cards = RApi::Card.new client
      unless cards.response["creditCardList"].blank?
        res = cards.delete params[:id]

        render status: 200, json: {message: res.description}
      else
        render status: 411, json: {message: "No tienes tarjetas para borrar"}
      end
    end
  end
end
