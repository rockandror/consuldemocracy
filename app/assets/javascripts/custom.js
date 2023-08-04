// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_ES.md#javascript
//
//
//= require cookies_eu

var initialize_modules = function() {
  "use strict";

  App.GoogleSearch.initialize();
  App.ConsentBanner.initialize();
};

$(document).on("turbolinks:load", initialize_modules);
