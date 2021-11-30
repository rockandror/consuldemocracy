App.LoginForm =

  initialize: ->

    registrationForm = $("form#new_user[action='/users/sign_in']")
    loginInput = $("input#user_login")
    recaptcha = $(".recaptcha")

    showRecaptchaFor = (login) ->
      request = $.get "/users/sessions/show_recaptcha?login=#{login}"
      request.done (response) ->
        if response.recaptcha
          recaptcha.show()
        else
          recaptcha.hide()

    if registrationForm.length > 0 and recaptcha.length > 0
      loginInput.on "focusout", ->
        login = loginInput.val()
        showRecaptchaFor(login) if login != ""
