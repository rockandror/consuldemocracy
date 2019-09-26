App.FoundationExtras =

  initialize: ->
    $(document).foundation()
    $(window).trigger "resize"

    $("#side_menu ul").on "down.zf.accordionMenu", (e) ->
      Foundation.reInit $("[data-equalizer]")

    clearSticky = ->
      $("[data-sticky]").foundation("destroy") if $("[data-sticky]").length

    $(document).on("page:before-unload", clearSticky)

    window.addEventListener("popstate", clearSticky, false)

    mobile_ui_init = ->
      $(window).trigger "load.zf.sticky"

    desktop_ui_init = ->
      $(window).trigger "init.zf.sticky"

    $ ->
      if $(window).width() < 620
        do mobile_ui_init
      else
        do desktop_ui_init
