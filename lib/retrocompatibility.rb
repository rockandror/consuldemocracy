module Retrocompatibility
  def self.calculate_value(setting_key, secret_key)
    Setting["#{setting_key}"].present? ? Setting["#{setting_key}"] : Rails.application.secrets[secret_key]
  end

end
