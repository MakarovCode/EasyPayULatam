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
    end
  end

  resources :pay_u_payments, only: [:index, :show, :edit, :update]
end
