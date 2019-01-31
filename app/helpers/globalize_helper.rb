module GlobalizeHelper
  def first_available_locale(resource)
    return I18n.locale if resource.present? && translations_with_locale?(resource, I18n.locale)

    return resource.translations.first.locale if resource.present? && resource.translations.any?

    I18n.locale
  end

  def translations_with_locale?(resource, locale)
    resource.present? && resource.translations.any? && resource.locales_not_marked_for_destruction.include?(locale)
  end

  def active_locales(resource, display_style)
    locale = first_available_locale(resource)
    options_for_select(available_locales(resource, display_style), locale)
  end

  def active_locales_description(resource)
    active_locales = 0
    if resource.present?
      active_locales = resource.locales_not_marked_for_destruction.size > 0 ? resource.locales_not_marked_for_destruction.size : 1
    end
    t("shared.translation_interface.languages_in_use", count: active_locales).html_safe
  end

  def available_locales(resource, display_style)
    options = []
    I18n.available_locales.each do |locale|
      next if display_style.call(locale) == "display: none;"
      options << [name_for_locale(locale), locale, { data: { locale: locale } }]
    end
    options
  end

  def highlight_translations_class
    return 'highlight' if translations_interface_enabled? && !backend_translations_enabled?
  end

  def display_translation?(resource, locale)
    first_available_locale(resource) == locale
  end

  def locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale, { data: { locale: locale } }]
    end
  end

  def display_language_style(resource, locale)
    "display: none;" unless display_language_option?(resource, locale)
  end

  def enable_translation_style(resource, locale)
    "display: none;" unless enable_locale?(resource, locale)
  end

  def display_language_option?(resource, locale)
    return locale == I18n.locale if !resource || resource.translations.empty?

    resource.locales_not_marked_for_destruction.include?(locale)
  end

  def enable_locale?(resource, locale)
    if resource.translations.any?
      resource.locales_not_marked_for_destruction.include?(locale)
    else
      locale == I18n.locale
    end
  end

  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def globalize(locale, &block)
    Globalize.with_locale(locale) do
      yield
    end
  end
end
