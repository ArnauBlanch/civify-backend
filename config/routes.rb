Rails.application.routes.draw do
  namespace :users do
    resources :search, only: [:create]
  end
  resources :issues, param: :issue_auth_token do
    member do
      resources :resolve, only: [:create, :index]
    end
  end
  resources :users, param: :user_auth_token do
    member do
      resources :issues, param: :issue_auth_token
    end
  end
  post '/login', to: 'authentication#login'
  get '/me', to: 'authorized_request#me'
  get '/issues', to: 'issues#index_issues'
  get '/issues/:issue_auth_token', to: 'issues#show_issue'
  put '/issues/:issue_auth_token', to: 'issues#update_issue'
  patch '/issues/:issue_auth_token', to: 'issues#update_issue'
  delete '/issues/:issue_auth_token', to: 'issues#destroy_issue'
end