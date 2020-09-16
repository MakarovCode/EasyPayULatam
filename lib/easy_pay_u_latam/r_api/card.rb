module EasyPayULatam
  module RApi
    class Card < Request
      attr_reader :url, :customer_url, :customer
      attr_accessor :resource, :params

      # creación de instancia de la clase
      # recibe un customer(cliente en payu) para asociar una tarjeta de crédito
      # customer = PayuLatam::Client.new
      def initialize(customer={})
        @params   = empty_object # inicializa los params de card con datos de prueba
        @customer = customer.response if !customer.nil?
        customer_url # llenar la @url con la de la api de cards
        return if @customer.nil?
        load("") # si llega id buscarlo
      end

      def customer
        @customer ||= { id: nil }
      end

      # llena la variable local y super con la url de este recurso
      def url
        @url ||= RApi.base_url + "/rest/#{RApi.api_version}/creditCards/"
      end

      # el recurso de tarjeta necesita en algunos casos alterar la URL para incluir información
      # del customer, por eso se crea este metodo con la url necesario
      def customer_url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/customers/#{@customer['id']}/creditCards/"
      end

      # se sobreescribe el metodo crear de request
      # el metodo crear necesita en la url información del customer por eso se llena la @url con la url
      # necesaria luego que continue con su flujo llamando super
      def create!
        customer_url
        super
      end

      # se sobreescribe el metodo load de request
      # obtener detalle de una tarjeta, para esto reestablecemos la url simple
      # continuar con el flujo normal llamando super
      def load(id)
        customer_url
        super
      end

      # se sobreescribe el metodo delete de request
      # eliminar tarjeta, para esto, para esto usar la url con la info del customer
      # continuar con el flujo normal llamando super
      def delete(token)
        customer_url
        super
      end

      # se sobreescribe el metodo update de request
      # recibe los parametros a editar y el id objetivo a editar
      def update(params={})
        reset_url
        @http_verb = 'Put'
        @url += id.to_s
        @params = params if !params.empty?
        http
        @response
      end

      # override from request
      def id
        raise ArgumentError, 'Card is nil' if @resource.nil?
        @resource['token'] if @resource
      end

      private

      # restablece url a su estado base
      def reset_url
        @url = RApi.base_url + "/rest/v4.9/creditCards/"
      end

      # ejemplo de parametro
      def empty_object
        {
          "name": "Sample User Name",
          "document": "1020304050",
          "number": "4242424242424242",
          "expMonth": "01",
          "expYear": "2020",
          "type": "VISA",
          "address": {
            "line1": "Address Name",
            "postalCode": "00000",
            "city": "City Name",
            "state": "State Name",
            "country": "CO",
            "phone": "300300300"
          }
        }
      end
    end
  end
end
