
module EasyPayULatam
  module RApi
    class Request

      require 'uri'
      require 'net/https'
      require 'json'

      # lectura y escritura
      attr_accessor :url, :_url, :params
      # solo lectura
      attr_reader :response, :http_verb, :error

      #
      # VARIABLES:
      #
      # @url       -> su valor es asignado por cada clase hija que use algún método de la clase request
      # @_url      -> url auxiliar, por ahora no tiene un uso
      # @params    -> objeto con los parametros que serán enviados en el body de la petición
      # @response  -> objeto con la respuesta json obtenida de la api de PAYU
      # @http_verb -> indica el verbo http a usar en la petición, GET, PUT, DELETE...
      # @error     -> objeto con la respuesta json del ERROR devuelto por payu
      #

      # POST Creación de registro
      # 'create' es un metodo POST en la api de PAYU para todos sus modulos. Card, Client, Plan, ...
      # ejecuta la petición y en caso de existir respuesta la guarda en la variable response
      def create!
        @http_verb = 'Post'
        http
        @response
      end

      # PUT Edición de registro
      # 'update' es un metodo PUT en la api de PAYU para todos sus modulos. Card, Client, Plan, ...
      # ejecuta la petición y en caso de existir respuesta la guarda en la variable response
      #
      # recibe como parametros los valores a enviar en el cuerpo de la petición, es decir los campos
      # del recurso que se desea editar con su respectivo valor
      def update(params={})
        @http_verb = 'Put'
        @url += id.to_s

        @params = params if !params.empty? # si llegan parametros se enviaran y editaran esos params
        @params.merge!({id: id}) if id

        http
        @response
      end

      # GET Detalle del registro
      # necesita el id del recurso en payu para obtener info
      def load(id)
        @http_verb = 'Get'
        @url += id.to_s
        http
        @response
      end

      # DELETE Eliminar recurso
      # necesita el id del recurso en payu
      def delete(id)
        @http_verb = 'Delete'
        @url += id.to_s
        http
        @response
      end

      # indica si la última petición realizada fué exitosa
      def success?
        @error.nil? && !@response.nil?
      end

      # indica si la última petición fallida
      def fail?
        !@error.nil?
      end

      # retorna el id del último recurso trabajado
      def id
        raise ArgumentError, 'customer is nil' if @resource.nil?
        @resource['id'] if @resource
      end

      private

      def url
        @url ||= _url
      end

      # reestablece la url en caso de ser necesario
      def reset_url
        @url = url
      end

      # ejecución de la petición
      def http
        puts "#{http_verb} #{@url}"
        uri = URI.parse(@url)
        https = Net::HTTP.new(uri.host,uri.port)

        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        net_class = Object.const_get("Net::HTTP::#{http_verb}")
        request = net_class.new(uri.path, initheader = {'Content-Type' =>'application/json'})

        request['Accept'] = 'application/json'
        request['Accept-language'] = 'es'
        request['Authorization']   = RApi.authorization

        request.body = @params.to_json
        request = https.request(request)

        reset_url

        # llena @response ó @error
        if request.is_a?(Net::HTTPSuccess)
          begin
            @response = JSON.parse(request.body)
          rescue
            @response = request.body
          end
          @error = nil
        else
          @response = nil
          @error = JSON.parse(request.body)
        end
      end
    end
  end
end
