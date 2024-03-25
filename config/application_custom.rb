require "ntlm/smtp"

module Consul
  class Application < Rails::Application
    # Set to true to enable database tables auditing
    config.auditing_enabled = Rails.application.secrets.auditing_enabled
    config.i18n.default_locale = :es
    config.i18n.available_locales = ["es"]
    config.time_zone = "Atlantic/Canary"

    config.autoload_paths << "#{Rails.root}/app/controllers/custom/concerns"
  end
end
