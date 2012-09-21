require 'capistrano/ext/multistage'

app_name = "RailsExampleApp"

set :application,   "http://198.101.248.196/"
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

  task :create_symlinks, :role => :app do
    #run "ln -nfs #{shared_path}/uploads #{release_path}/public/"
  end

  task :migrate, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} rake db:migrate"
  end

  task :seed, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} rake db:seed"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

end

after "deploy:update_code", "sunspot:stop"
after "deploy:update",  "deploy:cleanup"
after "deploy:symlink", "deploy:create_symlinks"
after "deploy:restart", "deploy:migrate"
after "deploy:migrate", "deploy:seed"

# Delayed Job

#before "deploy:restart", "delayed_job:stop"
#after  "deploy:restart", "delayed_job:start"
#after  "deploy:stop",    "delayed_job:stop"
#after  "deploy:start",   "delayed_job:start"
