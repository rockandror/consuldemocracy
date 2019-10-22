module Regional
  class Timezone

    def self.load_timezone
      return unless ActiveRecord::Base.connection.data_source_exists?("settings")
      setting_timezone = Setting["regional.time_zone.key"]

      Time.zone = setting_timezone if setting_timezone.present?
    end

  end
end
