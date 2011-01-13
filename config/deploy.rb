set :default_stage, "production"
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :ssh_options, { :forward_agent => true, :port => 2569 }
ssh_options[:port] = 2569
set :port, 2569


set :application, "phocoder-rb-rails-example"
#set :repository,  "svn+webessh://aws.webeprint.com/persistent/SVNROOT/phocoder-rb-rails-example/trunk"

#set :repository, "aws.webeprint.com:/persistent/GITROOT/phocoder-rb-rails-example.git" 
set :repository, "git://github.com/jagthedrummer/phocoder-rb-rails-example.git" 
set :local_repository, "git://github.com/jagthedrummer/phocoder-rb-rails-example.git" 

set :scm, :git
#set :scm_username, "gitolite"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :deploy_to, "/mnt/rails/#{application}"


set :user, "jgreen"
set :git_enable_submodules, 1



#ssh_options[:port] = 2569

set :monit_group, 'phocoder-rb-rails-example'


task :after_update_code, :roles => [:app,:backgroundrb],
:except => {:no_symlink => true} do
run <<-CMD
cd #{release_path} &&
 ln -s #{shared_path}/config/* #{release_path}/config/
CMD
end


desc <<-DESC
Restart the Passenger (mod_rails)
DESC
task :restart_passenger , :roles => :app do
  sudo "touch #{deploy_to}/current/tmp/restart.txt"
end





