module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :nl
    config.i18n.available_locales = [:en, :nl]
    config.time_zone = "Amsterdam"

    config.autoload_paths << "#{Rails.root}/app/mailers/custom"
  end
end
