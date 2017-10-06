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
  s.summary     = "Con esta gema puedes integrar el WebCheckout de PayU con unos simples pasos."
  s.description = "Con esta gema puedes integrar el WebCheckout de PayU con unos simples pasos."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency "rabl"
  s.add_dependency "jquery-rails"
  s.add_dependency "bootstrap-sass"
  s.add_dependency "sass-rails"

  s.add_development_dependency "pg"
end
