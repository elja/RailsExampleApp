require 'capistrano/ext/multistage'

app_name = "RailsExampleApp"

set :application,   "198.101.248.196"
set :scm,           :git
set :repository,    "git://github.com/elja/RailsExampleApp.git"
set :branch,        "master"

set :user,          "app"
set :runner,        user

set :deploy_to,     "/home/app/www/#{app_name}"
set :deploy_via,    :remote_cache
set :use_sudo,      false
set :keep_releases, 4

# Read from local system
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

set :rails_env, "production"

role :web, application
role :app, application
role :db,  application, :primary => true

namespace :deploy do
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{release_path}/tmp/restart.txt"
  end
end

