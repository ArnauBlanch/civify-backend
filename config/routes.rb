Rails.application.routes.draw do
  namespace :users do
    resources :search
  end
  resources :users, param: :user_auth_token
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'login', to: 'authentication#login'
  get 'me', to: 'authorized_request#me'
end