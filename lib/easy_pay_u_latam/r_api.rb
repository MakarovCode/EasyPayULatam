module EasyPayULatam
  module RApi
    class << self
      require "base64"
      # NOTA: definir si dejar estos campos como accessors
      attr_accessor :api_login, :api_key, :account_id, :sandbox, :api_version
      attr_reader   :base_url

      # recibe un bloque inicializador de variables de configuración de payu como la
      # api_key, api_login
      def configure(&block)
        block.call(self)
      end

      # retorna la url de api de payu dependiendo del ambiente, development o production
      def base_url
        if RApi.sandbox == true
          @base_url = 'https://sandbox.api.payulatam.com/payments-api'
        else
          @base_url = 'https://api.payulatam.com/payments-api'
        end
      end

      # genera el codigo de autenticación que será enviado en los header de todas las peticiones a la api
      def authorization
        @authorization ||= "Basic " + Base64.strict_encode64("#{api_login}:#{api_key}").to_s
      end
    end
  end

end
