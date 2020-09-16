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

  # #development
  # RApi.configure do |config|
  #   config.api_login  = 'pRRXKOl8ikMmt9u'
  #   config.api_key    = '4Vj8eK4rloUd272L48hsrarnUA'
  #   config.account_id = '512321'
  #   config.sandbox    = true
  #   config.api_version    = "v4.3"
  # end

  # production
  # RApi.configure do |config|
  #   config.api_login  = 'BtHXV5p7b1a74Za'
  #   config.api_key    = 'ZNl7g0L2H54Y9ZVn51keXS2l07'
  #   config.account_id = '762507'
  #   config.sandbox    = false
  #   config.api_version    = "v4.3"
  # end

end
