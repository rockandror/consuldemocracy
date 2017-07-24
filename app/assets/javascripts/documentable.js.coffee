App.Documentable =

  initialize: ->
    App.Documentable.initializeForm()

  initializeForm: ->

    if $('#sources input[type="radio"]:checked').length > 0
      App.Documentable.hide('#sources input[type="radio"]:not(:checked)')

    else
      first_source_option = $('#sources input[type="radio"]')[0]
      $(first_source_option).prop("checked", true)
      App.Documentable.hide('#sources input[type="radio"]:not(:checked)')

    $('#sources input[type=radio]').on 'change', (event) ->
      App.Documentable.hide('#sources input[type="radio"]')
      App.Documentable.show('.source-option-' + this.value)

  hide: (selector) ->
    elements_to_hide = $(selector)
    $.each elements_to_hide, (index, element) ->
      $('.source-option-' + element.value).hide()

  show: (selector) ->
    $(selector).show()