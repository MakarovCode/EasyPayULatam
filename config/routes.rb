EasyPayULatam::Engine.routes.draw do
  # devise_for :users, class_name: "EasyPayULatam::User"
  namespace :api do
    namespace :v1 do
      resources :pay_u_payments, only: [:index, :show] do
        member do
          post "confirmation"
          get "payed"
          get "get_status"
        end
      end

      resources :pay_u_cards, only: [:index, :create, :update, :destroy]
      resources :pay_u_clients, only: [:create]
      resources :pay_u_plans, only: [:index]
      resources :pay_u_subscriptions, only: [:index, :show, :create, :update, :destroy]
      resources :pay_u_additional_charges, only: [:create, :destroy]
    end
  end

  resources :pay_u_payments, only: [:index, :show, :edit, :update]
end
