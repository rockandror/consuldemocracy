ENV["RAILS_ENV"] ||= "test"
if ENV["COVERALLS_REPO_TOKEN"]
  require "coveralls"
  Coveralls.wear!("rails")
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/lib/"
    add_filter "/config/"
    add_filter "/db/"
  end
  puts("Coverage started...")
end

require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

Rails.application.load_tasks if Rake::Task.tasks.empty?

include Warden::Test::Helpers
Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.after do
    Warden.test_reset!
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => { args: %w(headless no-sandbox window-size=1200,600) }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :headless_chrome

Capybara.exact = true

OmniAuth.config.test_mode = true

Capybara.app = Rack::Builder.new do
  eval File.read(Rails.root.join("config.ru"))
end
