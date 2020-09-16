module EasyPayULatam
  module RApi
    class Client < Request
      attr_reader :url, :cards
      attr_accessor :resource, :params, :exists

      # puede recibir el id de un cliente, para obtener el detalle en la inicializacion de la clase
      def initialize(id=nil)
        url
        @params = empty_object
        @cards  = []
        return if id.nil?
        load(id)
      end

      # url base
      def url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/customers/"
      end

      private

      def empty_object
        { 'fullName'=> '', 'email'=> '' }
      end
    end
  end
end
