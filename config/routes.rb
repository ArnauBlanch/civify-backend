Rails.application.routes.draw do
  namespace :users do
    resources :search, only: [:create]
  end
  resources :users, param: :user_auth_token do
    member do
      resources :issues, param: :issue_auth_token
      resources :offered_awards, only: [:index, :create], param: :award_auth_token, controller: 'awards'
      resources :exchanged_awards, only: [:index], param: :award_auth_token, controller: 'exchanges'
      resources :coins, only: [:create]
      resources :badges, only: [:index]
    end
  end
  resources :issues, param: :issue_auth_token, only: [] do
    member do
      resources :resolve, only: [:create]
      resources :confirm, only: [:create], controller: 'confirmations'
      resources :report, only: [:create], controller: 'reports'
    end
  end
  resources :awards, param: :award_auth_token, only: [:show, :index, :update, :destroy] do
    member do
      resources :exchange, only: [:create], controller: 'exchanges'
    end
  end

  resources :use, param: :exchange_auth_token, only: [:create], controller: 'uses'

  # Achievements
  resources :achievements, param: :achievement_token
  post 'achievements/:achievement_token/claim', to: 'claim#claim_achievement'

  # Events
  resources :events, param: :event_token
  post 'events/:event_token/claim', to: 'claim#claim_event'

  # New achievements/events
  resources :new_achievements_events, only: [:index], controller: 'new_achievements_events'

  # Password reset
  resources :password_resets, only: [:create, :update]

  resources :can_create_issue, only: [:index]

  post '/login', to: 'authentication#login'
  get '/me', to: 'authorized_request#me'
  get '/issues', to: 'issues#index_issues'
  get '/issues/:issue_auth_token', to: 'issues#show_issue'
  put '/issues/:issue_auth_token', to: 'issues#update_issue'
  patch '/issues/:issue_auth_token', to: 'issues#update_issue'
  delete '/issues/:issue_auth_token', to: 'issues#destroy_issue'
end