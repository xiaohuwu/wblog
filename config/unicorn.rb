app_path = File.expand_path( File.join(File.dirname(__FILE__), '..', '..'))
puts "app_path: #{app_path}"
worker_processes   1
timeout            180
listen             "/data/www/wblog/tmp/sockets/unicorn.sock"
pid                "/data/www/wblog/tmp/pids/unicorn.pid"
stderr_path        "/data/www/wblog/shared/log/unicorn.log"
stdout_path        "/data/www/wblog/shared/log/unicorn.log"

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

before_exec do |server| # fix hot restart Gemfile
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/Gemfile"
end

