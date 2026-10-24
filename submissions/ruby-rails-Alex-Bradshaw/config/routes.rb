Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    get "tags", to: "tags#index"

    post "users", to: "users#create"
    post "users/login", to: "users#login"
    get "user", to: "users#show"
  end
end
