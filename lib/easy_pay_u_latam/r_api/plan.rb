module EasyPayULatam
  module RApi
    class Plan < Request
      attr_reader :url
      attr_accessor :resource, :params

      # in order to take the correct url
      def initialize(id=nil)
        url
        @params = empty_object
        return if id.nil?
        load(id)
      end

      def update(params={})
        @http_verb = 'Put'
        @url += id.to_s

        @params = params if !params.empty?
        http
        @resource = @response if @response
      end

      # override from request
      def id
        raise ArgumentError, 'plan is nil' if @resource.nil?
        @resource['planCode'] if @resource
      end

      def url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/plans/"
      end

      private

      def empty_object
        {
          "accountId": RApi.account_id,
          "planCode": "Utopicko-plan01",
          "description": "Suscripción Utopicko",
          "interval": "MONTH",#MONTH
          "intervalCount": "1",
          "maxPaymentsAllowed": "12",
          "paymentAttemptsDelay": "1",
          "trialDays": "0",
          "additionalValues": [
            {
              "name": "PLAN_VALUE",
              "value": "20000",
              "currency": "COP"
            }
          ]
        }
      end
    end
  end
end

# {"id"=>"f7bad364-29f9-4cc2-b0c1-c92e271803a1",
#  "planCode"=>"Utopicko-plan01",
#  "description"=>"Suscripci&oacute;n Utopicko",
#  "accountId"=>"512321",
#  "intervalCount"=>1,
#  "interval"=>"MONTH",
#  "maxPaymentsAllowed"=>12,
#  "maxPaymentAttempts"=>0,
#  "paymentAttemptsDelay"=>1,
#  "maxPendingPayments"=>0,
#
#  "trialDays"=>0,
#  "additionalValues"=>[{"name"=>"PLAN_VALUE", "value"=>20000, "currency"=>"COP"}]}
