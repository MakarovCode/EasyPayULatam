module EasyPayULatam
  module RApi
    class AdditionalCharge < Request
      attr_reader :url, :plan, :customer, :card, :sub_id
      attr_accessor :resource, :params

      def initialize(customer, sub_id)
        @customer = customer
        @sub_id = sub_id
        @customer = customer.response if !customer.nil?
        # @callback_url = callback_url
        @params = {}
        return if @customer.nil?
        # load("")
      end

      def create_url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/subscriptions/#{@sub_id}/recurringBillItems"
      end

      def url
        @url = RApi.base_url + "/rest/#{RApi.api_version}/recurringBillItems/"
      end

      def create!
        create_url
        super
      end

      def load(id)
        url
        super
      end

      def delete(id)
        url
        super
      end

    end
  end
end
