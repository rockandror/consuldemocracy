App.Managers =

  generatePassword: ->
    chars = "abcdefghijklmnopqrstuvwxyz"
    numbers = "123456789"
    pass = ""
    x = 0
    while x < 10
      i = Math.floor(Math.random() * chars.length)
      pass += chars.charAt(i)
      x++
    pass += chars.charAt(Math.floor(Math.random() * chars.length)).toUpperCase()
    pass += numbers.charAt(Math.floor(Math.random() * numbers.length))
    return pass

  togglePassword: (type) ->
    $('#user_password').prop 'type', type

  initialize: ->
    $(".generate-random-value").on "click", (event) ->
      password = App.Managers.generatePassword()
      $('#user_password').val(password)

    $(".show-password").on "click", (event) ->
      if $("#user_password").is("input[type='password']")
        App.Managers.togglePassword('text')
      else
        App.Managers.togglePassword('password')
