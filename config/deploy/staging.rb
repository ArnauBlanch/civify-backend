set :stage, :staging
server "civify.cf", user: "deploy", roles: %w{web app db}
set :branch, "develop"
set :deploy_to, "/var/www/civify-backend-staging"