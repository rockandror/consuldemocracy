# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

map (ENV['CONSUL_RELATIVE_URL'].nil? || ENV['CONSUL_RELATIVE_URL'].empty? ? '/' : ENV['CONSUL_RELATIVE_URL']) do
  run Rails.application
end
