set :stage, :production

role :app, %w{deploy@civify.cf}
role :web, %w{deploy@civify.cf}
role :db,  %w{deploy@civify.cf}