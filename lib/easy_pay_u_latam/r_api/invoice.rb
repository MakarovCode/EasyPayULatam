module PayuLatam
  class Invoice < Request
    attr_reader :url, :data
    attr_accessor :resource, :params

    # in order to take the correct url
    def initialize(data = {})
      @data = data
      @params = @data
      url
      _id
      load(@id)
    end

    def _id
      @id = @data[:customerId]     if !@data[:customerId].nil?
      @id = @data[:subscriptionId] if !@data[:subscriptionId].nil?
    end

    def load(id)
      raise ArgumentError, 'params are nil' if @data.nil?
      customer_url     if !@data[:customerId].nil?
      subscription_url if !@data[:subscriptionId].nil?

      if !@data[:customerId].nil? && !@data[:start_date].nil? && !@data[:end_date].nil?
        @dateBegin = @data[:start_date]
        @dateFinal = @data[:end_date]
        range_url
      end

      return if @id.nil?

      super
    end

    def url
      @url = PayuLatam.base_url + "/rest/#{RApi.api_version}/recurringBill"
    end

    def customer_url
      @url = url + '?customerId='
    end

    def subscription_url
      @url = url + '?subscriptionId='
    end

    # año día mes
    def range_url
      @url = url "?customerId=#{@id}&dateBegin=#{@dateBegin}&dateFinal=#{@dateFinal}"
    end
  end
end
