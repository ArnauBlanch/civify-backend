set :stage, :production
set :rails_env, :production
server "civify.cf", user: "deploy", roles: %w{web app db}
set :branch, "master"
set :deploy_to, "/var/www/civify-backend"