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

end
