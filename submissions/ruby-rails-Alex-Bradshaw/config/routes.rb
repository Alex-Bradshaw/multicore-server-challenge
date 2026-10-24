Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    get "tags", to: "tags#index"

    post "users", to: "users#create"
    post "users/login", to: "users#login"
    get "user", to: "users#show"
    put "user", to: "users#update"

    # Usernames can contain dots, which Rails would otherwise treat as a format extension (".json").
    scope format: false, constraints: { username: %r{[^/]+} } do
      get "profiles/:username", to: "profiles#show"
      post "profiles/:username/follow", to: "profiles#follow"
      delete "profiles/:username/follow", to: "profiles#unfollow"
    end
  end
end
