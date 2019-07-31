module Regional
  class Locales

    def self.load_default_and_available_locales
      return unless ActiveRecord::Base.connection.data_source_exists?("settings")
      load_i18n_default_locale
    end

    private

      def self.load_i18n_default_locale
        setting_default_locale = Setting["regional.default_locale.key"]
        I18n.default_locale = setting_default_locale.to_sym if setting_default_locale.present?
      end

  end

end
