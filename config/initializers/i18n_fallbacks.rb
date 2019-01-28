module I18nFallbacks
  class Loader
    def self.setup
      fallbacks = {}
      fallbacks = I18n.available_locales.map do |locale|
        fallbacks[locale] = (I18n.fallbacks[locale] + I18n.available_locales).uniq
      end
      I18n.fallbacks = I18n::Locale::Fallbacks.new(fallbacks)
    end
  end
end
