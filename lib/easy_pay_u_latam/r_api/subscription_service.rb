module PayuLatam
  class SubscriptionService < Request
    attr_reader :current_user
    
    # inicializa la clase actual
    # recibe los params del contexto que se envian desde el subscription_interceptor
    # recibe el current_user(active_record)
    def initialize(options = {}, current_user)
      @current_user = current_user
      options.each_pair do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # crea o carga el cliente en payu
    # se usa la informacion del curren_user para generar un cliente en payu en caso de no existir
    # se llena la variable @client con la respuesta de payu api
    def client
      # se intenta encontrar un cliente en payu con el campo payu_customer_id del usuario
      client = PayuLatam::Client.new(@current_user.payu_customer_id)
      # todas las peticiones del modulo eredan de request, eso da acceso al metodo success? indica si sale bien o no
      if client.success?
        # en caso de encontrar el usuario se llena la variable @client con la instancia de clase PayuLatam::Client
        @client = client
      else
        # si el usuario aun no es cliente en payu. se procede a crearlo
        # se sobreescriben los params con los valores del usuario
        client.params[:fullName] = @current_user.name
        client.params[:email] = @current_user.email
        client.create! # llamado al metodo creacion
        if client.success?
          # si la creacion es exitosa se almacena en la variable @client
          @client = client
          # El cliente ha sido creado en payu, esto retorna el id en payu del usuario
          # ese id lo asignamos al usuario en la BD
          @current_user.update_attribute(:payu_customer_id, @client.resource['id'])
        else
          # si la creacion falla, se lanza un error con el mensaje necesario
          # este error es interceptado y controlado
          raise StandardError, 'Error creando cliente/customer: '+ client.error.to_s
        end
      end
    end

    # crea o carga un plan en un cliente de payu
    # se utiliza el current_user, el payu_id del cliente y el plan_code del plan
    def plan
      # si el usuario no tiene plan_id en su modelo, se le asigna el plan_id seleccionado en el formulario
      # recordar que ese plan_id llega en los params del contexto y por tanto tenemos acceso a el
      # como variable de clase @plan_id

      if @current_user.plan_id.nil?
        if @plan_id.nil?
          raise StandardError, 'Error creando plan, plan_id null'
        end
        # se almacena en el user
        @current_user.update_attribute(:plan_id, @plan_id)
        # despues de tenerlo almacenado en la bd, llamamos nuevamente este metodo plan
        plan
      else
        # el usuario tiene un plan_id asignado, se le actualiza el plan_id en caso de que haya seleccionado uno
        # diferente al que tiene actualmente
        @current_user.update_attribute(:plan_id, @plan_id)
        # obtener informacion del plan de la BD
        plan_db = @current_user.plan
        #
        # NOTA: los planes deben tener un plan_code es OBLIGATORIO para el buen funcionamiento
        #
        if plan_db.plan_code.nil? || plan_db.plan_code.empty?
          raise StandardError, 'Error creando plan, code null'
        end
        # con el plan_code lo buscamos en payu
        plan_payu = PayuLatam::Plan.new(plan_db.plan_code)
        # si existe?
        if plan_payu.success?
          # llenar la variable plan con la instancia de clase PayuLatam:Plan
          @plan = plan_payu
        else
          # si no existe en pyu, crearlo con el metodo del modelo plan
          plan_db.create_payu_plan
          # llamado recursivo
          plan
        end
      end
    end

    # la respuesta de payu de client incluye un nodo con las tarjetas de credito del usuario asociadas en payu
    def cards
      @cards ||= @client.resource['creditCards']
    end

    # crear tarjeta de credito en payu
    # utiliza los params recibidos
    def create_card
      raise StandardError, 'Cliente null' if @client.nil?
      # la instancia de card recibe como parametro el @client al que se le va asociar la tarjeta
      card = PayuLatam::Card.new(@client)
      # hay un metodo card_params que genera el objeto a enviar con los datos correctos
      # se asignan los params correctos para la peticion
      card.params.merge! card_params

      # intento de creacion de tarjeta
      card.create!
      # si todo bien
      if card.success?
        # se llena la variable @card con la instancia de la clase PayuLatam::Card
        @card = card

        # no me acuerdo XD
        @client.remove_cards
        
        # se agrega la tarjeta al array de tarjetas del usuario. Ojo este array esta en memoria no necesariamente
        # es el mismo array de payu
        @client.add_card( card.response )

        # la respuesta de creacion de payu solo incluye el token de la tarjeta, entonces
        # volvemos a consultar la info almacenada en payu para recibier un poco mas de detalle y almacenarlo
        _card = card.load(card.response['token'])
        # se crea un registro de payu_card con la info publica de la tarjeta y el token de payu de la tarjeta
        @current_user.payu_cards.create(token: @card.response['token'], last_4: _card['number'], brand: _card['type'])
      else
        raise StandardError, "Error generando token de tarjeta: #{card.error}"
      end
    end

    # generar subscripcion
    # se envian los parametros necesarios, @plan, @client, callback de pago realizado
    #
    # NOTA: la url del callback debe ser creada en el modulo principal payu_latam.rb en las variables inicializadoras
    # TODO: hacer el cambio de la nota.
    def subscription!
      @subscription = PayuLatam::Subscription.new(@plan, @client, 'http://10d2e1a2.ngrok.io/payu/api/v1/subscriptions.json')
      @subscription.create!
      if @subscription.success?
        puts "Subscription creada!"
        @current_user.payu_subscriptions.create(subscription_params)
        @subscription
      else
        raise StandardError, "Error generando la subscripción: #{@subscription.error}"
      end
    end

    # busca la info de una tarjeta de payu
    def find_card
      @client.remove_cards
      card = PayuLatam::Card.new(@client) # info de payu
      card.load( PayuCard.find(@selected_card).token )
      @client.add_card({token: card.resource['token']})
    end


    # metodo principal de la clase
    # se encarga de cargar informacion de: cliente(customer), plan, tarjeta
    # una vez esa información esta lista, se realiza la subscripcion
    #
    # NOTA. Si por alguna razon alguno de los metodos de este archivo falla y saca error 500, el error
    # sera intercepato por la clase subscription_interceptor y manejado correctamente por el controlador
    def call
      # metodo que controla la carga de cliente(customer)
      client
      # metodo que controla la carga de plan
      plan
      # si dentro de los params recibidos se encuentra un numero de tarjeta de credito, quiere
      # decir que se desea generar una nueva tarjeta en payu
      if @card_number
        # generar nueva tarjeta
        create_card
      else
        # usar tarjeta previamente usada
        find_card
      end

      # crear subscripcion en payu usando la informacion previamente cargada en este metodo
      subscription!
    end

    private

    # sobreescribir los params por defecto con los datos reales
    def card_params
      {
        "name": @card_name,
        "document": @current_user.document,
        "number": @card_number,
        "expMonth": @card_exp_month,
        "expYear": @card_exp_year,
        "type": @card_type,
        "address": {
          "line1": @card_address,
          "postalCode": @card_postal_code,
          "city": @card_city_name,
          "country": "CO",
          "phone": @current_user.phone
        }
      }
    end

    # sobreescribir los params por defecto con los datos reales
    def subscription_params
      {
        "payu_id": @subscription.resource['id'],
        "current_period_start": @subscription.resource['currentPeriodStart'],
        "current_period_end": @subscription.resource['currentPeriodEnd'],
        "payu_plan": @subscription.resource['plan']
      }
    end
  end
end
