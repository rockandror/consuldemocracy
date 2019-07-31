module SettingsHelper

  def feature?(name)
    setting["feature.#{name}"].presence || setting["process.#{name}"].presence || setting["social.#{name}"].presence
  end

  def setting
    @all_settings ||= Hash[Setting.all.map { |s| [s.key, s.value.presence] }]
  end

  def social_feature?(setting)
    key = setting.key.split(".")
    key.first == "social" && key.last == "login"
  end

  def advanced_feature?(setting)
    key = setting.key.split(".")
    key.first == "advanced" && key.last == "http_basic_auth"
  end

  def smtp_feature?(setting)
    key = setting.key.split(".")
    key.first == "smtp" && key.last == "enable_starttls_auto"
  end

  def is_feature?(setting)
    social_feature?(setting) || advanced_feature?(setting) || smtp_feature?(setting)
  end
end
