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
    social_feature?(setting) || advanced_feature?(setting) || smtp_feature?(setting) || regional_feature?(setting) || feature?(setting.key.rpartition(".").last) || setting.key == "feature.map"
  end

  def regional_feature?(setting)
    key = setting.key.split(".")
    key.first == "regional" && key.second == "available_locale"
  end

  def options_for_default_locale
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def regional_setting?(setting)
    setting.type.rpartition(".").first == "regional"
  end

end
