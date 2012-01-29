set :application, "serverManager2"

set :scm, :git
set :remote, "missall"
set :repository,  "git@github.com:missall/serverManager.git"
set :branch, "master"
#set :git_enable_submodules, 1
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "58.196.13.123"                          # Your HTTP server, Apache/etc
role :app, "58.196.13.123"                          # This may be the same as your `Web` server
role :db,  "58.196.13.123", :primary => true # This is where Rails migrations will run

set :deploy_to, "/var/www/#{application}"
set :use_sudo,false
set :user, "www-data"
#set :password, "123456"
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

task :chmod, :roles => :web do
run "chmod -fR 755 #{deploy_to}/current/script/*"
end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
   [:start, :stop].each do |t|
     desc "#{t} task is a no-op with mod_rails"
     task t, :roles => :app do ; end
   end
end