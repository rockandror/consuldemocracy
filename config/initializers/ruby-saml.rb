path = "/home/deploy/consul/shared/log/ruby-saml.log"

OneLogin::RubySaml::Logging.logger = Logger.new(path) if Rails.env.staging?
