set :stage, :production
server "civify.cf", user: "deploy", roles: %w{web app db}
set :branch, "master"