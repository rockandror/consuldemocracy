require "ntlm/smtp"

module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :es
    config.i18n.available_locales = ["es"]
    config.time_zone = "Atlantic/Canary"

    config.autoload_paths << "#{Rails.root}/app/controllers/custom/concerns"
    config.autoload_paths << "#{Rails.root}/app/mailers/custom"
  end
end
