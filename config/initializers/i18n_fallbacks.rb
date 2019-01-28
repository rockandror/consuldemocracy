module I18nFallbacks
  class Loader
    def self.setup
      I18n.fallbacks = I18n.available_locales.each_with_object({}) do |locale, fallbacks|
        fallbacks[locale] = (I18n.fallbacks[locale] + I18n.available_locales).uniq
      end
    end
  end
end
