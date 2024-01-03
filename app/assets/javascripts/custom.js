// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_ES.md#javascript
//
//

var initialize_modules = function() {
  "use strict";
  App.Callout.initialize();
  App.CookiesConsent.initialize();
  App.GoogleSearch.initialize();
  App.Followable.initialize();
};

$(document).on("turbolinks:load", initialize_modules);
