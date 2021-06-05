module EasyPayULatam
  class Api::V1::PayUCardsController < ApiController

    acts_as_token_authentication_handler_for User

    def index
      client = RApi::Client.new current_user.pay_u_costumer_id
      cards = RApi::Card.new client
      unless cards.response["creditCardList"].blank?
        if cards.response["creditCardList"].count == 1
          if current_user.payu_default_card != cards.response["creditCardList"][0]["token"]
            current_user.update_attribute :payu_default_card, cards.response["creditCardList"][0]["token"]
          end
        end
        render status: 200, json: {cards: cards.response["creditCardList"]}
      else
        render status: 200, json: {cards: []}
      end
    end

    def create
      client = RApi::Client.new current_user.pay_u_costumer_id
      cards = RApi::Card.new client
      cards.params = params[:card].as_json
      cards.params["number"] = cards.params["number"].gsub(" ","")
      cards.params["expMonth"] = cards.params["expiry"].split(" / ")[0]
      cards.params["expYear"] = cards.params["expiry"].split(" / ")[1]
      cards.params.delete "expiry"
      cards.params.delete "cvc"
      response = cards.create!

      unless cards.response.blank?
        render status: 200, json: {message: "ok"}
      else
        msg = cards.error["errorList"].blank? ? cards.error["description"] : cards.error["errorList"].to_sentence
        render status: 411, json: {message: msg }
      end
    end

    def update
      client = RApi::Client.new current_user.pay_u_costumer_id
      current_user.update_attribute :payu_default_card, params[:id]
      #validat si tiene subscripciones y actualizar subscricion

      subs = RApi::Subscription.new client

      unless subs.response.blank?
        if !subs.response["creditCardList"].nil? && !subs.response["creditCardList"].empty?
          res = subs.update({"creditCardToken": params[:id]})

          unless subs.response.blank?
            render status: 200, json: {message: "ok"}
          else
            msg = subs.error["errorList"].blank? ? subs.error["description"] : subs.error["errorList"].to_sentence
            render status: 411, json: {message: msg }
          end
        else
          render status: 200, json: {message: "ok"}
        end
      else
        render status: 200, json: {message: "ok"}
      end
    end

    def destroy
      client = RApi::Client.new current_user.pay_u_costumer_id
      cards = RApi::Card.new client
      unless cards.response.blank?
        unless cards.response["creditCardList"].empty?
          res = cards.delete params[:id]

          render status: 200, json: {message: res["description"]}
        else
          render status: 411, json: {message: "No tienes tarjetas para borrar"}
        end
      else
        render status: 411, json: {message: "No tienes tarjetas para borrar"}
      end
    end
  end
end
