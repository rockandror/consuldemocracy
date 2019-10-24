module Retrocompatibility
  def self.calculate_value(setting_key, secret_key)
    Setting["#{setting_key}"].presence || Rails.application.secrets[secret_key]
  end
end
