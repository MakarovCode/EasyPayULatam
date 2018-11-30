(function () {
  var module = angular.module("subscriptions-module", ['gavruk.card']);

  module.controller('SubscriptionsController', ['$http', '$scope', '$compile', '$rootScope', function ($http, $scope, $compile, $rootScope) {

    var self = this;

    //Atributos de Clientes


    //Atributos de Tarjetas
    this.cards = [];

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

    this.init = function(uuid, token){
      this.user_uuid = uuid;
      this.user_token = token;
      this.ClearCard();
      this.GetClient();
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
        cvc: ''
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

    this.DeleteCard = function(card){
      var params = {
        user_email: self.user_uuid,
        user_token: self.user_token
      };

      $http.delete("/easy_pay_u_latam/api/v1/pay_u_cards/"+card.token+".json", {params: params}).then(
        function(res, status){
          for (var i = 0; i < cards.length; i++) {
            if (cards[i].token == card.token){
              cards.splice(i, 1);
              break;
            }
          }
        },
        function(res, status){
        }
      );
    }

    // $scope.$on("StartChangeUnit", function(event, args) {
    //   self.row = args.row;
    // });

  }]);
})();
