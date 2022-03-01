module Consul
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, "env.yml")
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    config.relative_url_root = ENV["RAILS_RELATIVE_URL_ROOT"]

    config.i18n.available_locales = %w[es]

    config.sites = {
      open_government: Rails.application.secrets.logo_canarias_government_url || "https://www.gobiernodecanarias.org/",
      transparency: Rails.application.secrets.transparency_url || "https://www.gobiernodecanarias.org/transparencia/",
      open_data: Rails.application.secrets.open_data_url || "https://datos.canarias.es/",
      citizen_participation: Rails.application.secrets.logo_citizen_participation_url || "https://www.gobiernodecanarias.org/participacionciudadana/"
    }
  end
end
