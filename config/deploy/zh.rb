set :domain, '47.106.115.20'
set :deploy_to, '/data/www/wblog'
set :repository, 'https://github.com/xiaohuwu/wblog.git'
set :branch, 'master'
set :user, 'root'
set :port, '3118'
set :puma_config, ->{ "#{fetch(:current_path)}/config/puma.rb" }
set :rvm_use_path, '/usr/local/rvm/bin/rvm'
