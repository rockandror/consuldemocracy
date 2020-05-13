(function() {
  "use strict";
  App.FoundationExtras = {
    mobile_ui_init: function() {
      $(window).trigger("load.zf.sticky");
    },
    desktop_ui_init: function() {
      $(window).trigger("init.zf.sticky");
    },
    initialize: function() {
      $(document).foundation();
      if ($(window).width() < 620) {
        App.FoundationExtras.mobile_ui_init();
      } else {
        App.FoundationExtras.desktop_ui_init();
      }
    }
  };
}).call(this);
