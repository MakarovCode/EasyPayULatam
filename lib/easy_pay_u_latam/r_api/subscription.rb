module EasyPayULatam
  module RApi
    class Subscription < Request
      attr_reader :url, :plan, :customer, :card
      attr_accessor :resource, :params

      def initialize(customer)
        @customer = customer
        @customer = customer.response if !customer.nil?
        # @callback_url = callback_url
        @params = {}
        return if @customer.nil?
        # load("")
      end

      def invoice_url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/recurringBill?customerId=#{@customer['id']}"
      end

      def url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/subscriptions/"
      end

      def create!
        url
        super
      end

      def load(id)
        invoice_url
        super
      end

      def delete(id)
        url
        super
      end

    end
  end
end
