Rails.application.routes.draw do
  namespace :users do
    resources :accounts
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
