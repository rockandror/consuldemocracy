module RegionalSettings
  extend ActiveSupport::Concern

  included do
    before_action :initialize_regional_settings
  end

  private

    def initialize_regional_settings
      Regional::Locales.load_default_and_available_locales
      Regional::Timezone.load_timezone
    end
end
