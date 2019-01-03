module RrglobalizeHelper

  def rr_options_for_locale_select
    options_for_select(rr_locale_options, nil)
  end

  def rr_locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale, { 'selected'=> rr_language_selected(@resource, locale), 'data-locale' => locale }]
    end
  end

  def rr_options_for_locale_select_add_language
    options_for_select(rr_locale_options_add_language, nil)
  end

  def rr_locale_options_add_language
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def rr_display_translation?(resource, locale)
    if !resource || resource.translations.blank? ||
        resource.translations.map(&:locale).include?(I18n.locale)
      locale == I18n.locale
    else
      locale == resource.translations.first.locale
    end
  end
  #
  def rr_display_translation_style(resource, locale)
    "display: none;" unless rr_display_translation?(resource, locale)
  end
  #
  # def translation_enabled_tag(locale, enabled)
  #   hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  # end
  #
  # def rr_enable_translation_style(resource, locale)
  #   "display: none;" unless rr_enable_locale?(resource, locale)
  # end
  #
  # def rr_enable_locale?(resource, locale)
  #   if resource.translations.any?
  #     resource.locales_not_marked_for_destruction.include?(locale)
  #   else
  #     locale == I18n.locale
  #   end
  # end
  #
  def rr_language_selected(resource, locale)
    "selected" if rr_display_translation?(resource, locale)
  end
  #
  # def globalize(locale, &block)
  #   Globalize.with_locale(locale) do
  #     yield
  #   end
  # end
  #
  # def same_locale?(locale1, locale2)
  #   locale1 == locale2
  # end

end
