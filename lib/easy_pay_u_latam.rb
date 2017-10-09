require "easy_pay_u_latam/engine"
require "easy_pay_u_latam/Configuration"

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
