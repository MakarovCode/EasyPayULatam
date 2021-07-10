$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "easy_pay_u_latam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "easy_pay_u_latam"
  s.version     = EasyPayULatam::VERSION
  s.authors     = ["DEVPENGUIN"]
  s.email       = ["simoncorreaocampo@gmail.com"]
  s.homepage    = "https://github.com/simoncorreaocampo/EasyPayULatam"
  s.summary     = "With this gem you can use PayU Latam Web Checkout and recurrent payments with some simple configuration step."
  s.description = "PayU Latam easy integration."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '>= 4.2.1'
  # s.add_dependency "rabl", '>= 0.9.3'
  # s.add_dependency "jquery-rails", '>= 4.1.1'
  # s.add_dependency "bootstrap-sass", '>= 3.3.6'
  # s.add_dependency "sass-rails", '>= 5.0'
  # s.add_dependency "angularjs-rails"
  # s.add_dependency 'rails-assets-sweetalert2'
  # s.add_dependency 'sweet-alert2-rails'

  s.add_development_dependency "pg", '>= 0.21.0'
end
