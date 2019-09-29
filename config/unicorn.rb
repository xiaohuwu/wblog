module Rails
  class << self
    def root
      File.expand_path("../..", __FILE__)
    end
  end
end

APP_HOME =  Rails.root
puts "APP_HOME: #{APP_HOME}"
worker_processes 2

working_directory APP_HOME # available in 0.94.0+

if 'production' == ENV['RAILS_ENV']
  listen "#{APP_HOME}/tmp/sockets/unicorn.sock", :backlog => 64
  pid "#{APP_HOME}/tmp/pids/unicorn.pid"
else
  listen 3006, :tcp_nopush => true
  pid "#{APP_HOME}/tmp/pids/unicorn.pid"
end

timeout 60

stderr_path "#{APP_HOME}/log/unicorn.stderr.log"
stdout_path "#{APP_HOME}/log/unicorn.stdout.log"

preload_app true

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

check_client_connection false

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{APP_HOME}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      puts "old_pid: #{old_pid}"
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Send 'QUIT' signal to unicorn error!"
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

