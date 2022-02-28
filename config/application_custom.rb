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
      open_government: ENV["LOGO_CANARIAS_GOVERNMENT_URL"] || "https://www.gobiernodecanarias.org/",
      transparency: ENV["TRANSPARENCY_URL"] || "https://www.gobiernodecanarias.org/transparencia/",
      open_data: ENV["OPEN_DATA_URL"] || "https://datos.canarias.es/",
      citizen_participation: ENV["LOGO_CITIZEN_PARTICIPATION_URL"] || "https://www.gobiernodecanarias.org/participacionciudadana/"
    }
  end
end
