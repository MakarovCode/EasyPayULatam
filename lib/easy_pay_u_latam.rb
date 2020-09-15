require "easy_pay_u_latam/engine"
require "easy_pay_u_latam/Configuration"
require "easy_pay_u_latam/r_api"
require "easy_pay_u_latam/r_api/request"
require "easy_pay_u_latam/r_api/plan"
require "easy_pay_u_latam/r_api/card"
require "easy_pay_u_latam/r_api/client"
require "easy_pay_u_latam/r_api/subscription"
require "easy_pay_u_latam/r_api/additional_charge"

module EasyPayULatam
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
