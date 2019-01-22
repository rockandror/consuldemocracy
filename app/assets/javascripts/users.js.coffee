App.Users =

  initialize: ->
    $('.initialjs-avatar').initial()
    false

    if $('body.admin').length
      $('.translation-locale, .translatable-fields').removeClass('highlight')
