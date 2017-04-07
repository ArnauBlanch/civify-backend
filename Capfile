require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/puma'


Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
