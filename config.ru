require_relative "config/boot"
require 'rack/cors'

use ReloadMiddleware if Settings.env == "development"

use Rack::Cors do
  allow do
    origins '*' # Allow requests from any origin
    resource '*', headers: :any, methods: [:get, :post, :options] # Allow GET, POST, and OPTIONS requests
  end
end

run -> (env) { Router.call(env) }.freeze