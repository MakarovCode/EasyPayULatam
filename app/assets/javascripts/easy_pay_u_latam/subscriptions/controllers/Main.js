
var EasyPayULatam = {
  init: function(){
    var module = angular.module('easy_pay_u_latam', ['subscriptions-module']);

    document.addEventListener("turbolinks:load", function() {
      var element = angular.element(document.querySelector('#easy_pay_u_latam'));

      var isInitialized = element.injector();
      if (!isInitialized) {
        angular.bootstrap(document.querySelector('#easy_pay_u_latam'), ['easy_pay_u_latam'])
      }
    });

    $(document).ready(function(){
      var element = angular.element(document.querySelector('#easy_pay_u_latam'));

      var isInitialized = element.injector();
      if (!isInitialized) {
        angular.bootstrap(document.querySelector('#easy_pay_u_latam'), ['easy_pay_u_latam'])
      }
    });

    module.directive('httpRequestLoader', ['$http', function($http) {
      return function(scope, element, attrs) {
        scope.html_loader = "<i class='fa-spin fa-2x fas fa-circle-notch active_loader'></i>";
        scope.active_loaders = [];
        scope.isLoading = function() {
          return {
            status: $http.pendingRequests.length > 0,
            requests: $http.pendingRequests
          };
        };
        setInterval(function(){
          scope.$evalAsync(function(){
            var res = scope.isLoading();
            //Verificar loaders ya no existentes
            for (var i = 0; i < scope.active_loaders.length; i++) {
              var loader = scope.active_loaders[i];
              var exists = false;
              for (var j = 0; j < res.requests.length; j++) {
                var req = res.requests[j];
                if (loader.url == req.url){
                  exists = true;
                  break;
                }
              }
              if (exists == false){
                //NO EXISTE YA LA PETICIÓN EN EL REQUESTS
                //QUITAR DEL HTML
                $(loader.target).find(".active_loader").remove();
              }
            }

            //Adicionar nuevos loaders
            for (var i = 0; i < res.requests.length; i++) {
              var req = res.requests[i];
              if (req.params != null && req.params._target != null){
                scope.active_loaders.push({url: req.url, target: req.params._target});
                //MOSTRAR LOADER EN HTML
                if ($(req.params._target).find(".active_loader").length == 0){
                  $(req.params._target).append(scope.html_loader);
                }
              }
            }
          });
        }, 1000);
        // scope.$watch(scope.isLoading, function(res, $http) {
        //   if (res.status){
        //     console.log("FINISH LOADING: " + res.requests.length);
        //     element.removeClass('ng-hide');
        //   }
        //   else{
        //     console.log("START LOADING: " + res.requests.length);
        //     element.addClass('ng-hide');
        //   }
        // });
      }
    }]);

    module.directive("inputCurrency", ["$locale","$filter", function ($locale, $filter) {

      // For input validation
      var isValid = function(val) {
        return angular.isNumber(val) && !isNaN(val);
      };

      // Helper for creating RegExp's
      var toRegExp = function(val) {
        var escaped = val.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
        return new RegExp(escaped, 'g');
      };

      // Saved to your $scope/model
      var toModel = function(val) {

        // Locale currency support
        var decimal = toRegExp($locale.NUMBER_FORMATS.DECIMAL_SEP);
        var group = toRegExp($locale.NUMBER_FORMATS.GROUP_SEP);
        var currency = toRegExp($locale.NUMBER_FORMATS.CURRENCY_SYM);

        // Strip currency related characters from string
        val = val.replace(decimal, '').replace(group, '').replace(currency, '').trim();

        return parseInt(val, 10);
      };

      // Displayed in the input to users
      var toView = function(val) {
        return $filter('currency')(val, '$', 0);
      };

      // Link to DOM
      var link = function($scope, $element, $attrs, $ngModel) {
        $ngModel.$formatters.push(toView);
        $ngModel.$parsers.push(toModel);
        $ngModel.$validators.currency = isValid;

        $element.on('keyup', function() {
          $ngModel.$viewValue = toView($ngModel.$modelValue);
          $ngModel.$render();
        });
      };

      return {
        restrict: 'A',
        require: 'ngModel',
        link: link
      };
    }]);


    module.filter('myCurrency', ['$filter', function ($filter) {
      return function(input) {
        input = parseFloat(input);

        if(input % 1 === 0) {
          input = input.toFixed(0);
        }
        else {
          input = input.toFixed(2);
        }

        return '$' + input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      };
    }]);

    module.directive('onLastRepeat', function() {
      return function(scope, element, attrs) {
        if (scope.$last) setTimeout(function(){
          scope.$emit('onRepeatLast', element, attrs);
        }, 1);
      };
    });

  }

}
