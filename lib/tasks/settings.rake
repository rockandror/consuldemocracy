namespace :settings do
  desc "Add new settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new settings"
    Setting.add_new_settings
  end

  desc "Rename existing settings"
  task rename_setting_keys: :environment do
    ApplicationLogger.new.info "Renaming existing settings"
    Setting.rename_key from: "feature.facebook_login", to: "social.facebook.login"
    Setting.rename_key from: "feature.google_login", to: "social.google.login"
    Setting.rename_key from: "feature.twitter_login", to: "social.twitter.login"
  end

  desc "Add new settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new settings"
    Setting.add_new_settings
  end

  desc "Manage settings"
  task manage_settings: [:rename_setting_keys, :add_new_settings]

  desc "Copy http basic auth from secrets to settings"
  task copy_http_basic_auth_to_settings: :environment do
    Setting["advanced.auth.http_basic_auth"] = Rails.application.secrets["http_basic_auth"]
    Setting["advanced.auth.http_basic_username"] = Rails.application.secrets["http_basic_username"]
    Setting["advanced.auth.http_basic_password"] = Rails.application.secrets["http_basic_password"]
  end

end
