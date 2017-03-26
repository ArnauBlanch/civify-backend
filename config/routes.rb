Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, param: :user_auth_token do
    member do
      resources :issues, param: :issue_auth_token
    end
  end
end
