require "ntlm/smtp"

module Consul
  class Application < Rails::Application
    config.devise_lockable = Rails.application.secrets.devise_lockable
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es]
    # Set to true to enable user authentication log
    config.authentication_logs = Rails.application.secrets.dig(:security, :authentication_logs) || false
  end
end
