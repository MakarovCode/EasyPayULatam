# EasyPayULatam
With this gem you can integrate the WebCheckout of PayU Latam with simple steps.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'easy_pay_u_latam'
```

We strongly recommend using Devise gem, this gem use current_user and some other devise methods for fetching user payments.
```ruby
gem 'devise'
```

And then execute:
```bash
$ bundle install
```

Then run
```bash
$ rails easy_pay_u_latam:install:migrations
```

If you want to reference the payments to a user, you can run the following migration.
```bash
$ rails g migration AddUserReferencesToEasyPayULatamPayuPayments user:references
```

Only run this when recurrent payments are ON, save the customer_id and default_credit_card for each user, you must run the following migration.
```bash
$ rails g migration AddPayUFieldsToUsers payu_default_card:string payu_customer_id:string
```

Only run this when recurrent payments are ON, extra fields for recurrent payments on payments table, you must run the following migration.
```bash
$ rails g migration AddRecurrentPaymentsToEasyPayULatamPayuPayments payu_plan_id:string payu_plan_code:string payu_customer_id:string payu_subscription_id:string trial_days:integer payu_credit_card_token:string  additional_charges_data:string
```

If you want to keep a reference to plans, before this you must have created a plan model on your project, you can run the following migration (User only when recurrent payments are ON).
```bash
$ rails g migration AddPlanReferencesToPlan payu_plan_id:string payu_plan_code:string
```

Don't forget to mount Engine in your routes.rb
```ruby
# config/routes.rb
mount EasyPayULatam::Engine, at: "/easy_pay_u_latam"
```

And precompile the engine assets (PayU logos).
```ruby
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( easy_pay_u_latam/* )
```

## Configuration
First create a easy_pay_u_latam.rb in your config/initializers
```ruby
# config/initializers/easy_pay_u_latam.rb
EasyPayULatam.configure do |config|
  config.api_key = "YOUR PAY U LATAM API KEY"
  config.account_id = "YOUR PAY U ACCOUNT ID"
  config.merchant_id = "YOUR PAY U MERCHANT ID"
  config.placeholder = "SOME PLACE HOLDER FOR PAY U REFERENCE CODE"
  config.root_url = "ROOT URL FOR PRODUCTION"
  #Pay U will consume a Web Service and it can not be in localhost, you most use something like ngrok
  config.test_root_url = "ROOT URL FOR TESTING"
  config.currency_precision = 2 #By default is 0 for colombian peso
  config.testing = true #Set false in production
end

# This keys are different, the recursive API use other keys
EasyPayULatam::RApi.configure do |config|
  config.api_login  = 'YOUR KEY'
  config.api_key    = 'YOUR KEY'
  config.account_id = 'YOUR PAY U ACCOUNT ID'
  config.sandbox    = true #Set false in production
  config.api_version    = "v4.3"
end
```

You can tell the engine which layout to use by overriding the application_controller
```ruby
# app/controllers/easy_pay_u_latam/application_controller.rb
module EasyPayULatam
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout "app/layouts/application"
  end
end
```

You should override the engine application_mailer so it can send success and error emails after PayU confirmation.
```ruby
# app/mailers/easy_pay_u_latam/application_mailer.rb
module EasyPayULatam
  class ApplicationMailer < ActionMailer::Base
    # You can also tell the engine which mailer layout to use
    layout 'easy_pay_u_latam/mailer'
    default from: 'Placeholder <test@example.com>'
  end
end
```

Finally create some method on any of you controllers that create the instance and data base record of the PayUPayment, you must especify amount, currency and description, period. The fields start_date, and end_date are optionals if you are using this gem for subscriptions like payments.

This is the method your should link with an anchor or button, it will automatically redirect to the web checkout view you need before redirecting to PayU.
```ruby
@payu_payment = EasyPayULatam::PayuPayment.create(
			amount: amount,
			currency: "COP",
			period: params[:period],
			user_id: current_user.id,
			description: "Your description here...",
			start_date: Date.today,
			end_date: end_date
		)

		redirect_to "/easy_pay_u_latam/pay_u_payments/#{@payu_payment.id}/edit?user_id=#{current_user.id}"
```

## Contributing
This gem is stable but it have a lot of room for improvement, is my first gem so a lot of thing could be better, feel free to help and share.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
