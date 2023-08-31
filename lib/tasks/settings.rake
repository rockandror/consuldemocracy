namespace :settings do
  desc "Add new settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new settings"
    Tenant.run_on_each { Setting.add_new_settings }
  end

  desc "Rename existing settings"
  task rename_setting_keys: :environment do
    ApplicationLogger.new.info "Renaming existing settings"
  end

  desc "Remove deprecated settings"
  task remove_deprecated_settings: :environment do
    deprecated_keys = [
      "login_attempts_before_lock",
      "time_to_unlock"
    ]

    deprecated_keys.each do |key|
      Setting.where(key: key).first&.destroy
    end
  end
end
