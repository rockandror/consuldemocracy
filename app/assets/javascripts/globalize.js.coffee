App.Globalize =

  display_locale: (locale) ->
    App.Globalize.enable_locale(locale)
    $("#globalize_locale .js-globalize-locale").each ->
      if $(this).data("locale") == locale
        $(this).addClass('is-active')

    $(".js-globalize-locale-link").each ->
      if $(this).data("locale") == locale
        $(this).removeClass('hide')
        $(this).addClass('show')
        App.Globalize.highlight_locale($(this))
      $(".js-globalize-locale option:selected").removeAttr("selected");
      return

  display_translations: (locale) ->
    $(".js-globalize-attribute").each ->
      if $(this).data("locale") == locale
        $(this).show()
      else
        $(this).hide()
      $('.js-delete-language').hide()
      $('#js_delete_' + locale).show()

  highlight_locale: (element) ->
    $('#globalize_locale').val(element.val())
    $('.js-globalize-locale-link').removeClass('is-active')
    element.addClass('is-active')
    App.Globalize.show_destroy_languages_buttons()

  show_destroy_languages_buttons: ->
    numLanguages = $('#globalize_locale option.show').length
    $('#num-languages').text(numLanguages)

    if  $('#globalize_locale option.show').length > 1
      $('.group-destroy-languages').show()
    else
      $('.group-destroy-languages').hide()

  remove_language: (locale) ->
    $(".js-globalize-attribute[data-locale=" + locale + "]").each ->
      $(this).val('').hide()
      if CKEDITOR.instances[$(this).attr('id')]
          CKEDITOR.instances[$(this).attr('id')].setData('')
    $(".js-globalize-locale-link[data-locale=" + locale + "]").toggleClass('show hide')

    next = $('#globalize_locale option:selected').removeAttr('selected').closest('#globalize_locale').find('.show').attr('selected', 'selected')
    App.Globalize.highlight_locale(next)
    App.Globalize.display_translations(next.data("locale"))
    App.Globalize.disable_locale(locale)

  enable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(false)
    App.Globalize.site_customization_enable_locale_field(locale).val(1)

  disable_locale: (locale) ->
    App.Globalize.destroy_locale_field(locale).val(true)
    App.Globalize.site_customization_enable_locale_field(locale).val(0)

  enabled_locales: ->
    $.map(
      $(".js-globalize-locale-link:visible"),
      (element) -> $(element).data("locale")
    )

  destroy_locale_field: (locale) ->
    $("input[id$=_destroy][data-locale=" + locale + "]")

  site_customization_enable_locale_field: (locale) ->
    $("#enabled_translations_" + locale)

  refresh_visible_translations: ->
    locale = $('.js-globalize-locale-link.is-active').data("locale")
    App.Globalize.display_translations(locale)

  initialize: ->
    $("#globalize_locale").each ->
      $(this).find('option').addClass('js-globalize-locale-link hide')
      $("#globalize_locale .js-globalize-locale-link").each ->
        if $(this).hasClass("is-active")
          $(this).removeClass('hide')
          $(this).addClass('show')
      App.Globalize.show_destroy_languages_buttons()

    $('.js-globalize-locale').on 'change', ->
      App.Globalize.display_translations($(this).val())
      App.Globalize.display_locale($(this).val())

    $('#globalize_locale').on 'change', ->
        locale = $(this).val()
        App.Globalize.display_translations(locale)
        App.Globalize.highlight_locale($(this))
        $('.js-globalize-locale-link').removeClass('is-active')
        $(this).find(':selected').addClass('is-active')

    $('.js-globalize-locale-link').on 'click', ->
      locale = $(this).data("locale")
      App.Globalize.display_translations(locale)
      App.Globalize.highlight_locale($(this))

    $('.js-delete-language').on 'click', (evt) ->
      locale = $(this).data("locale")
      $(this).hide()
      App.Globalize.remove_language(locale)
      evt.stopPropagation()
      evt.preventDefault()

    $(".js-add-fields-container").on "cocoon:after-insert", ->
      $.each(
        App.Globalize.enabled_locales(),
        (index, locale) -> App.Globalize.enable_locale(locale)
      )
