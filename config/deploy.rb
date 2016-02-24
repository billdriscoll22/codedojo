set :application, "codedojo"
set :repository, "ssh://codedojo@codedojo.stanford.edu/home/codedojo/codedojo.git"

set :user, 'codedojo'
set :branch, 'release'

set :git_shallow_clone, 1
set :use_sudo, false
set :deploy_to, "/var/www/codedojo"
set :deploy_via, :copy
set :keep_releases, 1
set :rails_env, "production"
set :migrate_target, :latest

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "codedojo.stanford.edu"                          # Your HTTP server, Apache/etc
role :app, "codedojo.stanford.edu"                          # This may be the same as your `Web` server
role :db,  "codedojo.stanford.edu", :primary => true # This is where Rails migrations will run


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "install the necessary prereqs"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install --deployment"
end

after "deploy:update_code", :bundle_install
