module EasyPayULatam
  class Configuration
    attr_accessor :api_key, :merchant_id, :account_id, :placeholder, :root_url, :test_root_url, :payu_url, :test_api_key, :test_merchan_id, :test_account_id, :test_payu_url, :currency_precision, :testing

    def initialize
      # Path for PayU responses
      @currency_precision = 0
      @root_url = nil
      @test_root_url = nil

      @placeholder = nil

      # For production
      @api_key = nil
      @merchant_id = nil
      @account_id = nil
      @payu_url = "https://gateway.payulatam.com/ppp-web-gateway/"

      # For testing
      @test_api_key = "4Vj8eK4rloUd272L48hsrarnUA"
      @test_merchant_id = "508029"
      @test_account_id = "512321"
      @test_payu_url = "https://sandbox.checkout.payulatam.com/ppp-web-gateway-payu"

      @testing = false
    end

    def get_api_key
      if @testing == true
        @test_api_key
      else
        @api_key
      end
    end

    def get_merchant_id
      if @testing == true
        @test_merchant_id
      else
        @merchant_id
      end
    end

    def get_account_id
      if @testing == true
        @test_account_id
      else
        @account_id
      end
    end

    def get_payu_url
      if @testing == true
        @test_payu_url
      else
        @payu_url
      end
    end

    def get_root_url
      if @testing == true
        @test_root_url
      else
        @root_url
      end
    end
  end
end
