App.RegistrationForm =

  initialize: ->

    path = window.location.pathname.split("/user")[0]
    registrationForm = $("form#new_user[action=\"" + path + "/users\"]")
    usernameInput = $("input#user_username")

    clearUsernameMessage = ->
      $("small").remove()

    showUsernameMessage = (response) ->
      klass = if response.available then "no-error" else "error"
      usernameInput.after $("<small class=\"#{klass}\" style=\"margin-top: -16px;\">#{response.message}</small>")

    validateUsername = (username) ->
      request = $.get path + "/user/registrations/check_username?username=#{username}"
      request.done (response) ->
        showUsernameMessage(response)


    if registrationForm.length > 0
      usernameInput.on "focusout", ->
        clearUsernameMessage()
        username = usernameInput.val()
        validateUsername(username) if username != ""
