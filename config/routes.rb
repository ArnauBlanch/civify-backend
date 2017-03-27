Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, param: :user_auth_token do
    member do
      resources :issues, param: :issue_auth_token
    end
  end

  get '/issues', to: 'issues#index_issues'
  get '/issues/:issue_auth_token', to: 'issues#show_issue'
  put '/issues/:issue_auth_token', to: 'issues#update_issue'
  patch '/issues/:issue_auth_token', to: 'issues#update_issue'
  delete '/issues/:issue_auth_token', to: 'issues#destroy_issue'
end
