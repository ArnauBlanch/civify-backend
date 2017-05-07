Rails.application.routes.draw do
  namespace :users do
    resources :search, only: [:create]
  end
  resources :users, param: :user_auth_token do
    member do
      resources :issues, param: :issue_auth_token
      resources :offered_awards, param: :award_auth_token, controller: 'awards'
      resources :coins, only: [:create]
    end
  end
  resources :issues, param: :issue_auth_token, only: [] do
    member do
      resources :resolve, only: [:create]
      resources :confirm, only: [:create], controller: 'confirmations'
      resources :report, only: [:create], controller: 'reports'
    end
  end
  resources :awards, param: :award_auth_token, only: [:show, :index, :update, :destroy]

  post '/login', to: 'authentication#login'
  get '/me', to: 'authorized_request#me'
  get '/issues', to: 'issues#index_issues'
  get '/issues/:issue_auth_token', to: 'issues#show_issue'
  put '/issues/:issue_auth_token', to: 'issues#update_issue'
  patch '/issues/:issue_auth_token', to: 'issues#update_issue'
  delete '/issues/:issue_auth_token', to: 'issues#destroy_issue'
end