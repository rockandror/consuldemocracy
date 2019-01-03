App.RRGlobalize =

  display_locale: (locale) ->
    #App.RRGlobalize.enable_locale(locale)
    $("#change_language_selector option").each ->
      if $(this).data("locale") == locale
        $(this).toggleClass('hide show')
        App.RRGlobalize.active_language($(this))
      $(".js-globalize-locale option:selected").removeAttr("selected");

  display_translations: (locale) ->
    $(".js-globalize-attribute").each ->
      if $(this).data("locale") == locale
        $(this).show()
      else
        $(this).hide()
      $('.js-delete-language').hide()
      $('#js_delete_' + locale).show()

  active_language: (element) ->
    $('#change_language_selector').val(element.val())
    App.RRGlobalize.number_languages()

  remove_language: (locale) ->
    $(".js-globalize-attribute[data-locale=" + locale + "]").each ->
      $(this).val('').hide()
      if CKEDITOR.instances[$(this).attr('id')]
          CKEDITOR.instances[$(this).attr('id')].setData('')
    $("#change_language_selector option[data-locale=" + locale + "]").toggleClass('show hide')

    find_nearby_language = $('#change_language_selector option:selected').removeAttr('selected').closest('#change_language_selector').find('.show').attr('selected', 'selected')
    App.RRGlobalize.active_language(find_nearby_language)
    App.RRGlobalize.display_translations(find_nearby_language.data("locale"))
    #App.RRGlobalize.disable_locale(locale)
    App.RRGlobalize.visible_option_add_language(locale)

  visible_option_add_language: (locale) ->
    $('.js-add-language').find("option[value='" + locale + "']").show()

  change_language_selector: ->
    $("#change_language_selector").each ->
      $(this).find('option').addClass('hide')
      $(this).find(":selected").toggleClass("hide show")

    locale = $("#change_language_selector").find(":selected").val()
    $('.js-add-language').find('option[value^="'+ locale + '"]').hide()

    $('#change_language_selector').on 'change', ->
        locale = $(this).val()
        App.RRGlobalize.display_translations(locale)
        App.RRGlobalize.active_language($(this))

    $('#change_language_selector option').on 'click', ->
      locale = $(this).data("locale")
      App.RRGlobalize.display_translations(locale)
      App.RRGlobalize.active_language($(this))

  add_language_selector: ->
    $('.js-add-language').on 'change', ->
      App.RRGlobalize.display_translations($(this).val())
      App.RRGlobalize.display_locale($(this).val())
      $(this).find('option:selected').hide()
      $(this).val($(".js-add-language option:first").val())

  number_languages: ->
    numLanguages = $('#change_language_selector option.show').length
    $('#num-languages').text(numLanguages)
    if  $('#change_language_selector option.show').length > 1
      $('.group-destroy-languages').show()
    else
      $('.group-destroy-languages').hide()

  destroy_languages_button: ->
    $('.js-delete-language').on 'click', (evt) ->
      locale = $(this).data("locale")
      $(this).hide()
      App.RRGlobalize.remove_language(locale)
      evt.stopPropagation()
      evt.preventDefault()

  # enable_locale: (locale) ->
  # App.RRGlobalize.destroy_locale_field(locale).val(false)
    #App.RRGlobalize.site_customization_enable_locale_field(locale).val(1)

  # disable_locale: (locale) ->
  #   App.RRGlobalize.destroy_locale_field(locale).val(true)
    #App.RRGlobalize.site_customization_enable_locale_field(locale).val(0)

  # enabled_locales: ->
  #   $.map(
  #     $(".js-select-language:visible"),
  #     (element) -> $(element).data("locale")
  #   )

  # destroy_locale_field: (locale) ->
  #   $("input[id$=_destroy][data-locale=" + locale + "]")

  # site_customization_enable_locale_field: (locale) ->
  #   $("#enabled_translations_" + locale)

  # refresh_visible_translations: ->
  #   locale = $('.js-select-language.is-active').data("locale")
  #   App.RRGlobalize.display_translations(locale)

  initialize: ->
    App.RRGlobalize.change_language_selector()
    App.RRGlobalize.add_language_selector()
    App.RRGlobalize.destroy_languages_button()
    App.RRGlobalize.number_languages()
