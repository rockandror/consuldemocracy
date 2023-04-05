require "ntlm/smtp"

module Consul
  class Application < Rails::Application
    config.devise_lockable = Rails.application.secrets.devise_lockable
  end
end
