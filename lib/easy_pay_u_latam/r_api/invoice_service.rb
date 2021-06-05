module PayuLatam
  class InvoiceService < Request
    attr_accessor :start_date, :end_date
    attr_reader :current_user, :invoices

    def initialize(current_user)
      @current_user = current_user
    end

    def current
      if @invoices.nil?
        @start_date.nil? && @end_date.nil? ? historical : range_dates
      end
      @invoices['recurringBillList'].last
    end

    private

    def historical
      @invoices = PayuLatam::Invoice.new(customerId: @current_user.payu_customer_id).resource
    end

    def range_dates
      raise ArgumentError, 'dates are nil' if @start_date.nil? && @end_date.nil?

      @invoices = PayuLatam::Invoice.new(customerId: @current_user.payu_customer_id,
        start_date: @start_date, end_date: @end_date).resource
    end
  end
end
=begin
# Ejemplo de respuesta
# <PayuLatam::Invoice:0x007fe1e41b54b8
  @data={:customerId=>"3a097xfyjj8y", :start_date=>"2018-16-10", :end_date=>"2018-16-11"},
  @dateBegin="2018-16-10",
  @dateFinal="2018-16-11",
  @error=nil,
  @http_verb="Get",
  @id="3a097xfyjj8y",
  @params={:customerId=>"3a097xfyjj8y", :start_date=>"2018-16-10", :end_date=>"2018-16-11"},
  @resource=
  {"recurringBillList"=>
    [{"id"=>"841c254e-8c6e-45d5-93f1-0fe33fb2bf55", "orderId"=>7341246, "subscriptionId"=>"4627edvl1je2", "state"=>"PAID", "amount"=>49, "currency"=>"MXN", "dateCharge"=>1461992400000},
     {"id"=>"a473e716-7839-4b4d-b20a-583797c737e0", "orderId"=>7344250, "subscriptionId"=>"0906e8zysve", "state"=>"PAID", "amount"=>10000, "currency"=>"COP", "dateCharge"=>1462424400000},
     ]
  }

=end