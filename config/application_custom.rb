module Consul
  class Application < Rails::Application
    config.autoload_paths << "#{Rails.root}/app/mailers/custom"
  end
end
