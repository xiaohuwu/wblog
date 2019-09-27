require ::File.expand_path('../config/environment',  __FILE__)
run WBlog::Application

require 'rack/cors'
use Rack::Cors do

  # allow all origins in development
  allow do
    origins '*'
    resource '*',
             :headers => :any,
             :methods => [:get, :post, :delete, :put, :options]
  end
end