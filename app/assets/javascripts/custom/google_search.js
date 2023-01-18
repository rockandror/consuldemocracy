(function () {
  "use strict";
  App.GoogleSearch = {
    initGoogleSearch: function () {
      $.ajax({
        url: "https://cse.google.com/cse.js?cx=1267aa4dbd8c37804",
        dataType: "script",
        success: () => console.log("OK Google Search!"),
      });
    },
    initialize: function () {
      App.GoogleSearch.initGoogleSearch();
    },
  };
}.call(this));
