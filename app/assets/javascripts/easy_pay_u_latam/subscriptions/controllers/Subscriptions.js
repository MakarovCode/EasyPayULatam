(function () {
  var module = angular.module("subscriptions-module", ['gavruk.card', 'puigcerber.countryPicker', 'ngSanitize']);

  module.controller('SubscriptionsController', ['$http', '$scope', '$compile', '$rootScope', function ($http, $scope, $compile, $rootScope) {

    var self = this;
    //Atributos de Planes
    this.actual_plan = null;
    this.selected_plan = null;
    this.last_payment = null;
    this.is_buyer = false;
    this.plans = [];

    //Atributos de Subscripciones
    this.subscriptions = [];
    this.subscription_loading = false;
    this.create_subscription_after_new_card = false;

    //Atributos de Tarjetas
    this.user_default_card = null;
    this.cards = [];
    this.card_loading = false;

    this.cardPlaceholders = {
      name: 'Nombre...',
      number: 'xxxx xxxx xxxx xxxx',
      expiry: 'MM/YY',
      cvc: 'xxx'
    };

    this.cardMessages = {
      validDate: 'valid\nthru',
      monthYear: 'MM/YYYY',
    };

    this.cardOptions = {
      debug: false,
      formatting: true,
      width: 500 //optional
    };

    this.init = function(uuid, token, plans, is_buyer, last_payment, actual_plan){
      this.user_uuid = uuid;
      this.user_token = token;
      this.is_buyer = is_buyer;
      this.last_payment = last_payment;
      this.actual_plan = actual_plan;

      this.ClearCard();
      this.GetClient();
      //No tengo ni idea porque me toco hacer eso pero sin el timeout simplemente el ng-repeat no renderiza plans
      setTimeout(function(){
        $scope.$evalAsync(function(){
          self.SetPlans(plans);
        });
      }, 100);

      $('#new-credit-card-modal').on('shown.bs.modal', function () {
        if (self.create_subscription_after_new_card == true){
          swal({
            title: 'Confirmación',
            text: "Cargaremos a tu tarjeta principal mensualmente el valor del plan hasta que canceles la subscripción.",
            type: 'info',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si, continuar',
            cancelButtonText: "Cancelar"
          }).then((result) => {
            if (result) {
              $scope.$evalAsync(function(){
                ('#new-credit-card-modal').modal("show");
              });
            }
            else{
              self.create_subscription_after_new_card = false;
            }
          });
        }
      })
    }

    //Métodos de Clientes

    this.GetClient = function(){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token
      };

      $http.post("/easy_pay_u_latam/api/v1/pay_u_clients.json", params).then(
        function(res, status){
          self.GetCards();
          self.GetSubscriptions();
        },
        function(res, status){
        }
      );
    }

    //Métodos de Tarjetas

    this.ClearCard = function(){
      this.card = {
        name: '',
        number: '',
        expiry: '',
        cvc: '',
        type: '',
        document: '',
        address: {
          line1: '',
          city: '',
          state: '',
          country: '',
          phone: ''
        }
      };
    }

    this.GetCards = function(){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token
      };

      $http.get("/easy_pay_u_latam/api/v1/pay_u_cards.json", {params: params}).then(
        function(res, status){
          self.cards = res.data.cards;
        },
        function(res, status){
        }
      );
    }

    this.GetCardType = function(){
      var card_ele = $(".jp-card").first();
      var classes = card_ele.prop("class");
      this.card.type = classes.split(" ")[1].split("-")[2].toUpperCase();
      if (this.card.type == "IDENTIFIED"){
        this.card.type = classes.split(" ")[2].split("-")[2].toUpperCase();
      }
    }

    this.CreateCards = function(){
      this.GetCardType();

      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token,
        card: this.card
      };

      this.card_loading = true;

      $http.post("/easy_pay_u_latam/api/v1/pay_u_cards.json", params).then(
        function(res, status){
          self.card_loading = false;
          self.ClearCard();
          self.GetCards();
          $("#new-credit-card-modal").modal("hide");
          swal("¡Excelente!", "¡La tarjeta de crédito creada con éxito!", "success");

          //Si el usuario seleccinó un plan se crea la subscripción automaticamente
          if (self.create_subscription_after_new_card == true){
            self.CreateSubscription();
          }
        },
        function(res, status){
          self.card_loading = false;
          swal("¡Información!", res.data.message, "error");
        }
      );
    }

    this.MarkAsPrimaryCard = function(card){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token
      };

      $http.put("/easy_pay_u_latam/api/v1/pay_u_cards/"+card.token+".json", params).then(
        function(res, status){
          self.user_default_card = card.token;
          swal("¡Excelente!", "¡Tarjeta marcada como primaria correctamente!", "success");
        },
        function(res, status){
          swal("¡Información!", res.data.message, "error");
        }
      );
    }

    this.DeleteCard = function(card){
      swal({
        title: '¿Estás seguro(a)?',
        text: "¡Está acción no se puede deshacer! Siempre puedes volver a adicionar la tarjeta como un nuevo medio de pago.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, continuar',
        cancelButtonText: "Cancelar"
      }).then((result) => {
        if (result) {
          $scope.$evalAsync(function(){
            var params = {
              user_email: self.user_uuid,
              user_token: self.user_token
            };

            $http.delete("/easy_pay_u_latam/api/v1/pay_u_cards/"+card.token+".json", {params: params}).then(
              function(res, status){
                for (var i = 0; i < self.cards.length; i++) {
                  if (self.cards[i].token == card.token){
                    self.cards.splice(i, 1);
                    break;
                  }
                }
                swal("¡Información!", "¡La tarjeta de crédito ha sido eliminada con éxito!", "success");
              },
              function(res, status){
                swal("¡Información!", res.data.message, "error");
              }
            );
          });
        }
      });
    }

    //Métodos de Subscripciones
    this.GetSubscriptions = function(){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token
      };

      $http.get("/easy_pay_u_latam/api/v1/pay_u_subscriptions.json", {params: params}).then(
        function(res, status){
          self.subscriptions = res.data.subscriptions;
        },
        function(res, status){
        }
      );
    }

    this.IntToDate = function(int){
      var date = new Date(int);
      return date;
    }

    //Métodos Planes
    this.SetPlans = function(plans){
      this.plans = plans;
    }

    this.ChangePlan = function(){
      this.selected_plan = null;
    }

    this.SelectPlan = function(plan){

      if (this.actual_plan != null && this.actual_plan.id == plan.id){
        swal("Información", "Actualmente estás estas suscrito a este plan.", "info");
        return;
      }

      swal({
        title: 'Confirmación',
        text: "Cargaremos a tu tarjeta principal mensualmente el valor del plan hasta que canceles la subscripción.",
        type: 'info',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, continuar',
        cancelButtonText: "Cancelar"
      }).then((result) => {
        if (result) {
          $scope.$evalAsync(function(){
            self.selected_plan = plan;

            if (self.cards.length > 0){
              //Crear suscripcion
              self.CreateSubscription();
            }
            else{
              //Pedir creación de tarjeta (Abrir modal)
              //Luego Crear suscripcion en el callback del create
              self.create_subscription_after_new_card = true;
              $("#new-credit-card-modal").modal("show");
            }
          });
        }
      });

    }

    //Métodos Subscripciones
    this.CreateSubscription = function(){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token,
        subscription: {
          quantity: "1",
          installments: "1",
          immediatePayment: true,
          trialDays: "15",
          customer: {
            id: "",
            creditCards: [
              {
                token: ""
              }
            ]
          },
          plan: {
            planCode: this.selected_plan.payu_plan_code
          }
        }
      };

      this.subscription_loading = true;

      $http.post("/easy_pay_u_latam/api/v1/pay_u_subscriptions.json", params).then(
        function(res, status){
          self.subscription_loading = false;
          //Mirar si se muestra alerta y se fuerza un refresh
          //O recirbir respuesta json y actualizar variables necesarias desde el API
          swal("Información", "Estamos procesando tu pago", "success");
          window.location.reload();
        },
        function(res, status){
          self.subscription_loading = false;
          swal("Información", res.data.message, "warning");
        }
      );
    }

    this.DeleteSubscription = function(){
      swal({
        title: 'Confirmación',
        text: "Volverás al plan Grátis una vez se caduque el plan que tenías.",
        type: 'info',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, continuar',
        cancelButtonText: "Cancelar"
      }).then((result) => {
        if (result) {
          $scope.$evalAsync(function(){
            var params = {
              user_email: self.user_uuid,
              user_token: self.user_token
            };

            this.subscription_loading = true;

            $http.delete("/easy_pay_u_latam/api/v1/pay_u_subscriptions/0000.json", {params: params}).then(
              function(res, status){
                self.subscription_loading = false;
                swal("Información", res.data.message, "success");
                window.location.reload();
                //Mirar si se muestra alerta y se fuerza un refresh
                //O recirbir respuesta json y actualizar variables necesarias desde el API
              },
              function(res, status){
                self.subscription_loading = false;
                swal("Información", res.data.message, "warning");
              }
            );
          });
        }
      });
    }

    // $scope.$on("StartChangeUnit", function(event, args) {
    //   self.row = args.row;
    // });

  }]);
})();
