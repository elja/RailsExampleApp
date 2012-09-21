#for multistage deployment
require "capistrano/ext/multistage"

#for bundler
require "bundler/capistrano"

#for rvm support
require "rvm/capistrano"

set :rvm_install_type, :stable

#for delayed job
#require "delayed/recipes"

set :stages, %w(staging production)

set :default_stage, "production"

set :default_environment, {
    'LC_ALL' => 'en_US.UTF-8',
    'LANG'   => 'en_US.UTF-8'
}

namespace :assets do
  desc "Create a symlink for application.css (used by static pages)"
  task :static, :roles => :web, :except => { :no_release => true } do
    %w(application.css).each do |asset|
      file = capture "cd #{shared_path}/assets && ruby -ryaml -e 'p YAML.load_file(\"manifest.yml\")[\"#{asset}\"]'"
      run "cd #{shared_path}/assets && ln -sf #{file.chomp} #{asset}"
    end
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/"

    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink

    run "cd #{release_path} && bundle install --without development test"
  end
end


before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'
after "deploy:finalize_update", "deploy:symlink_config"
after "deploy:update_code", "deploy:migrate"
after "deploy:restart", "deploy:cleanup"