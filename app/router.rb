# router.rb
require "roda"

class Router < Roda
  include Helpers

  plugin :json
  plugin :json_parser
  plugin :all_verbs
  plugin :request_headers
  #plugin :route_csrf, require_request_specific_tokens: false, check_header: true
  plugin :path
  plugin :hash_routes
  plugin :render, views: Settings.root.join("app/views")

  plugin :error_handler do |e|
    response.status = 500
    { error: { message: e.message, type: e.class.to_s } }
  end

  path(:link) { |link| "/link/#{link.id}" }

  # Load route files
  Dir[File.join(__dir__, "routes", "*.rb")].each { |file| require file }

  route do |r|
    #check_csrf!
    r.hash_routes
  end
end
