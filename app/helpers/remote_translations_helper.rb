include RemoteTranslations::Microsoft::AvailableLocales
module RemoteTranslationsHelper

  def display_remote_translation_info?(remote_translations, locale)
    locales = RemoteTranslations::Microsoft::AvailableLocales.get_available_locales
    locale = RemoteTranslations::Microsoft::AvailableLocales.parse_locale(locale)
    remote_translations.present? && locales.include?(locale.to_s)
  end
end
