include RemoteTranslations::Microsoft::AvailableLocales
module RemoteTranslationsHelper

  def display_remote_translation_info?(remote_translations, locale)
    translatable_locale = RemoteTranslations::Microsoft::AvailableLocales.include_locale?(locale)

    remote_translations.present? && translatable_locale
  end

  def display_remote_translation_button?(remote_translations)
    remote_translations.none? do |remote_translation|
      RemoteTranslation.remote_translation_enqueued?(remote_translation)
    end
  end
end
