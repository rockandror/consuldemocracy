App.Globalize =

  add_locale: (locale) ->
    App.Globalize.add_locale_option(locale)
    App.Globalize.display_translations(locale)
    App.Globalize.display_locale(locale)
    App.Globalize.update_description()

  remove_locale: (locale) ->
    $(".js-globalize-attribute[value=#{locale}]").each ->
      $(this).val('').hide()
      if CKEDITOR.instances[$(this).attr('id')]
        CKEDITOR.instances[$(this).attr('id')].setData('')

    $(".js-select-locale option[value=#{locale}]").remove()
    next = App.Globalize.first_available_locale()
    App.Globalize.display_translations(next.data("locale"))
    App.Globalize.disable_locale(locale)
    App.Globalize.update_description()

  change_locale: (locale) ->
    if !locale
      locale = App.Globalize.first_available_locale().val()
      App.Globalize.first_available_locale().prop('selected', true)
    App.Globalize.display_translations(locale)

  first_available_locale: ->
    $(".js-select-locale option[data-locale]").first()

  display_locale: (locale) ->
    App.Globalize.enable_locale(locale)
    App.Globalize.get_locale_option(locale).show().prop('selected', true)
    $(".js-add-locale option:selected").removeAttr("selected");

  display_translations: (locale) ->
    App.Globalize.get_locale_option(locale).prop('selected', true)
    $(".js-globalize-attribute").hide()
    $(".js-globalize-attribute[data-locale=#{locale}]").show()
    $('.js-delete-language').hide()
    $(".js-delete-#{locale}").show()

  site_customization_enable_locale_field: (locale) ->
    $("#enabled_translations_#{locale}")

  enable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(false)
    App.Globalize.site_customization_enable_locale_field(locale).val(1)

  disable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(true)
    App.Globalize.site_customization_enable_locale_field(locale).val(0)

  enabled_locales: ->
    $.map(
      $('.js-select-locale:first option'),
      (element) -> $(element).data('locale')
    )

  destroy_locale_field: (locale) ->
    $("input[id$=_destroy][data-locale=#{locale}]")

  refresh_visible_translations: ->
    locale = $('.js-select-locale').find('option:selected').data('locale')
    App.Globalize.display_translations(locale)

  update_description: ->
    count = App.Globalize.enabled_locales().length
    text = $('.globalize-languages').data('multiple-language-text')
    if count == 1
      text = $('.globalize-languages').data('single-language-text')
    $('.js-languages-text').text(text)
    $('.js-languages-count').text(count)

  get_locale_option: (locale) ->
    $(".js-select-locale option[value=#{locale}]")

  add_locale_option: (locale) ->
    if App.Globalize.get_locale_option(locale).length == 0
      $(".js-select-locale").append($(".js-add-locale option[value=#{locale}]").clone())

  remove_locale_option: (locale) ->
    App.Globalize.get_locale_option(locale).remove()

  initialize: ->
    $('.js-add-locale').on 'change', ->
      App.Globalize.add_locale($(this).val())

    $('.js-select-locale').on 'change', ->
      App.Globalize.change_locale($(this).val())

    $('.js-delete-language').on 'click', (e) ->
      e.preventDefault()
      $(this).hide()
      App.Globalize.remove_locale($(this).data('locale'))

    $('.js-add-fields-container').on 'cocoon:after-insert', ->
      $.each(
        App.Globalize.enabled_locales(),
        (index, locale) -> App.Globalize.enable_locale(locale)
      )
