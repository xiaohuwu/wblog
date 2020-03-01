require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/unicorn'
require 'mina/rvm'
require "mina_sidekiq/tasks"


#set :application_name, 'foobar'
set :domain, '47.106.115.20'
set :deploy_to, '/data/www/wblog'
set :repository, 'https://github.com/xiaohuwu/wblog.git'
set :branch, 'master'

set :user, 'root'          # Username in the server to SSH to.
set :port, '3118'           # SSH port number.
# set :domain, '39.106.152.138'
set :rvm_path, '/usr/local/rvm/bin/rvm'

set :app_path, lambda { "#{deploy_to}/#{current_path}" }
set :stage, 'production'

set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'config/yetting.yml', 'log', 'config/symmetric-encryption.yml', 'public/uploads']

set :sidekiq_pid, "#{deploy_to}/tmp/pids/sidekiq.pid"
set :unicorn_pid, "#{deploy_to}/tmp/pids/unicorn.pid"

set :rails_env, 'production'
set :unicorn_env, 'production'

task :environment do
  invoke :'rvm:use[ruby-ruby-2.5.0]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/tmp/sockets/"]
  queue! %[mkdir -p "#{deploy_to}/tmp/pids/"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/bin"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/bin"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/yetting.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue! %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]

  queue %[
    repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
    if [ -z "${repo_port}" ]; then repo_port=22; fi &&
    ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  ]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
  end

  deploy do
    #invoke :'sidekiq:quiet'

    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      to :launch do
        invoke :'sidekiq:restart'
        invoke :'unicorn:restart'
      end
    end
  end
end
