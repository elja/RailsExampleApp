#for multistage deployment
require "capistrano/ext/multistage"

#for bundler
require "bundler/capistrano"

#for rvm support
require "rvm/capistrano"

set :stages, %w(staging production)
set :default_stage, "production"

# utf-8 fix
#set :default_environment, {
#    'LC_ALL' => 'en_US.UTF-8',
#    'LANG'   => 'en_US.UTF-8'
#}

namespace :deploy do
  task :symlink_config, roles: :app do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :seed, roles: :app do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  end
end

set :rvm_install_type, :stable

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

after "deploy:finalize_update", "deploy:symlink_config"
after "deploy:update_code", "deploy:migrate"
after "deploy:restart", "deploy:cleanup"

# Delayed Job

#before "deploy:restart", "delayed_job:stop"
#after  "deploy:restart", "delayed_job:start"
#after  "deploy:stop",    "delayed_job:stop"
#after  "deploy:start",   "delayed_job:start"