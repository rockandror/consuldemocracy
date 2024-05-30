// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_ES.md#javascript
//
//

var initialize_modules = function() {
  "use strict";

  App.CookiesConsent.initialize();
  App.GoogleSearch.initialize();
};

$(document).on("turbolinks:load", initialize_modules);
