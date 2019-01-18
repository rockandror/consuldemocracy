module GlobalizeHelper

  def first_available_locale(resource)
    return I18n.locale if translations_with_locale?(resource, I18n.locale)

    return resource.translations.first.locale if resource.translations.any?

    I18n.locale
  end

  def translations_with_locale?(resource, locale)
    resource.translations.any? && resource.translations.reject(&:_destroy).map(&:locale).include?(locale)
  end

  def active_languages(resource)
    locale = first_available_locale(resource)
    options_for_select(available_locales(resource), locale)
  end

  def available_locales(resource)
    options = []
    I18n.available_locales.each do |locale|
      options << [name_for_locale(locale), locale , { style: display_language_style(resource, locale), data: { locale: locale } }]
    end
    options
  end

  def active_languages_text(resource)
    active_languages = resource.translations.reject(&:_destroy).map(&:locale).size > 0 ? resource.translations.reject(&:_destroy).map(&:locale).size : 1
    t("shared.translation_interface.languages_in_use", count: active_languages).html_safe
  end

  def highlight_translations_class
    return 'highlight' if translations_interface_enabled?
  end

  # For div with translations fields
  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  def display_translation?(resource, locale)
    if !resource || resource.translations.blank? ||
       resource.locales_not_marked_for_destruction.include?(I18n.locale)
      locale == I18n.locale
    else
      locale == resource.translations.first.locale
    end
  end

  # For active languages selector
  def display_language_style(resource, locale)
    "display: none;" unless display_language_option?(resource, locale)
  end

  def display_language_option?(resource, locale)
    return locale == I18n.locale if resource.translations.empty?

    resource.translations.reject(&:_destroy).map(&:locale).include?(locale)
  end

  # For destroy links
  def display_destroy_locale_style(resource, locale)
    "display: none;" unless display_destroy_locale_link?(resource, locale)
  end

  def display_destroy_locale_link?(resource, locale)
    first_available_locale(resource) == locale
  end

  def display_destroy_locale?(resource, locale)
    if resource.translations.empty? || (resource.translations.any? && resource.translations.size == 1)
      false
    else
      display_language_option?(resource, locale)
    end
  end

  def options_for_locale_select
    options_for_select(locale_options, nil)
  end

  def first_available_locale(resource)
    return I18n.locale if translations_with_locale?(resource, I18n.locale)

    return resource.translations.first.locale if resource.translations.any?

    I18n.locale
  end

  def translations_with_locale?(resource, locale)
    resource.translations.any? && resource.translations.reject(&:_destroy).map(&:locale).include?(locale)
  end

  def active_languages(resource)
    locale = first_available_locale(resource)
    options_for_select(available_locales(resource), locale)
  end

  def available_locales(resource)
    options = []
    I18n.available_locales.each do |locale|
      options << [name_for_locale(locale), locale , { style: display_language_style(resource, locale), data: { locale: locale } }]
    end
    options
  end

  def active_languages_text(resource)
    active_languages = resource.translations.reject(&:_destroy).map(&:locale).size > 0 ? resource.translations.reject(&:_destroy).map(&:locale).size : 1
    t("shared.translation_interface.languages_in_use", count: active_languages).html_safe
  end

  def locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  # For active languages selector
  def display_language_style(resource, locale)
    "display: none;" unless display_language_option?(resource, locale)
  end

  def display_language_option?(resource, locale)
    return locale == I18n.locale if resource.translations.empty?

    resource.translations.reject(&:_destroy).map(&:locale).include?(locale)
  end

  # For destroy links
  def display_destroy_locale_style(resource, locale)
    "display: none;" unless display_destroy_locale_link?(resource, locale)
  end

  def display_destroy_locale_link?(resource, locale)
    first_available_locale(resource) == locale
  end

  def display_destroy_locale?(resource, locale)
    if resource.translations.empty? || (resource.translations.any? && resource.translations.size == 1)
      false
    else
      display_language_option?(resource, locale)
    end
  end
end
