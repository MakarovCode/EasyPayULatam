module PayuLatam
  class SubscriptionInterceptor
    # recibe la información de contexto y genera una instancia de si mismo para llamar el 
    # metodo de instancia run, retorna el objeto de instancia generado
    def self.call(context)
      interactor = new(context) # objeto nuevo, instancia de esta misma clase
      interactor.run # metodo principal de la clase
      interactor
    end

    attr_reader :error

    # metodo inicializador de las clases en ruby
    # recibe el contexto enviado
    # recordar que el contexto es enviado desde el controlador, por lo tanto contiene toda
    # la información del request htto, entre ellos los params y el current_user
    def initialize(context)
      @context = context
    end

    # si no hay error, es que todo salió bien
    def success?
      @error.nil?
    end

    # metodo principal de esta clase
    # al estar en un 'rescue' evitamos que el proyecto saque error 500 cuando algo sale mal
    # INTERCEPTAMOS el error y lo enviamos al controller para que trabaje con el
    #
    # de la variable @context, obtenemos los params y el current_user
    # en los params se encuentran datos del plan , tarjeta de crédito seleccionada o datos de nueva tarjeta
    #
    # se ejecuta el metodo 'call' del SubscriptionService
    def run
      PayuLatam::SubscriptionService.new(context.params, context.current_user).call
    rescue => exception
      fail!(exception.message)
    end

    private

    attr_reader :context

    # metodo bang de error
    # recibe un mensaje de error y lo almacena en la variable de instancia @error
    # esta variable es usado por el controlador para verificar si ha ocurrido un error
    def fail!(error)
      @error = error
    end
  end
end