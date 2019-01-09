App.Globalize =

  display_locale: (locale) ->
    App.Globalize.enable_locale(locale)
    $("#globalize_locale option[data-locale=" + locale + "]").show().prop('selected', true)
    $(".js-translation-locale option:selected").removeAttr("selected");

  display_translations: (locale) ->
    $("#globalize_locale option[data-locale=" + locale + "]").prop('selected', true)
    $(".js-globalize-attribute").each ->
      if $(this).data("locale") == locale
        $(this).show()
      else
        $(this).hide()
      $(".js-delete-language").hide()
      $("#js_delete_#{locale}").show()

  remove_language: (locale) ->
    $(".js-globalize-attribute[data-locale=" + locale + "]").each ->
      $(this).val('').hide()
      if CKEDITOR.instances[$(this).attr('id')]
          CKEDITOR.instances[$(this).attr('id')].setData('')

    $("#globalize_locale option[data-locale=" + locale + "]").hide()
    next = $("#globalize_locale option:visible[data-locale]").first()
    App.Globalize.display_translations(next.data("locale"))
    App.Globalize.disable_locale(locale)
    App.Globalize.update_description()

    if $("#globalize_locale option:visible").length == 1
      $("#globalize_locale option:visible").prop('selected', true)

  enable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(false)
    App.Globalize.site_customization_enable_locale_field(locale).val(1)

  disable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(true)
    App.Globalize.site_customization_enable_locale_field(locale).val(0)

  enabled_locales: ->
    $.map(
      $("#globalize_locale option:visible"),
      (element) -> $(element).data("locale")
    )

  destroy_locale_field: (locale) ->
    $("input[id$=_destroy][data-locale=#{locale}]")

  site_customization_enable_locale_field: (locale) ->
    $("#enabled_translations_#{locale}")

  refresh_visible_translations: ->
    locale = $(".js-globalize-locale-link.is-active").data("locale")
    App.Globalize.display_translations(locale)

  update_description: ->
    count = App.Globalize.enabled_locales().length
    App.Globalize.update_languages_count(count)
    App.Globalize.update_languages_text(count)

  update_languages_count: (count) ->
    $('.js-languages-count').text(count)

  update_languages_text: (count) ->
    text = $(".globalize-languages").data('multiple-language-text')
    if count == 1
      text = $(".globalize-languages").data('single-language-text')
    $('.js-languages-text').text(text)

  initialize: ->
    # Add selected language
    $('.js-translation-locale').on 'change', ->
      locale = $(this).val()
      App.Globalize.display_translations(locale)
      App.Globalize.display_locale(locale)
      App.Globalize.update_description()

    # Change active language
    $('#globalize_locale').on 'change', ->
      locale = $(this).find('option:selected').data("locale")
      App.Globalize.display_translations(locale)

    # Destroy language
    $('.js-delete-language').on 'click', (e) ->
      e.preventDefault()
      locale = $(this).data("locale")
      $(this).hide()
      App.Globalize.remove_language(locale)

    # Only needed for legislation questions
    $(".js-add-fields-container").on "cocoon:after-insert", ->
      $.each(
        App.Globalize.enabled_locales(),
        (index, locale) -> App.Globalize.enable_locale(locale)
      )
