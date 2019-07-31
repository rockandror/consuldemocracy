module Regional
  class Locales

    def self.load_default_and_available_locales
      return unless ActiveRecord::Base.connection.data_source_exists?("settings")
      load_i18n_default_locale
      load_i18n_available_locales
    end

    private

      def self.load_i18n_default_locale
        setting_default_locale = Setting["regional.default_locale.key"]
        I18n.default_locale = setting_default_locale.to_sym if setting_default_locale.present?
      end

      def self.load_i18n_available_locales
        all_settings = Setting.all.group_by { |setting| setting.type }
        settings = all_settings["regional.available_locale"]
        return if settings.blank?

        I18n.available_locales = load_available_locales_keys(settings)
      end

      def self.load_available_locales_keys(settings)
        settings_available_locales = []

        settings.each do |available_locale|
          if Setting["#{available_locale.key}"].present?
            settings_available_locales << available_locale.key.rpartition(".").last.to_s
          end
        end

        settings_available_locales
      end
  end

end
