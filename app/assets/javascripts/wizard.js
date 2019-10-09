(function() {
  "use strict";
  App.Wizard = {
    selecKind: function() {
      $("#verification_field_kind").on("change", function() {
        var selected = $(this).find(":selected").val();
        var checkBoxLink = $("#input-checkbox-link");
        selected == "checkbox" ? checkBoxLink.show() : checkBoxLink.hide();
      });
    },
    initialize: function() {
      App.Wizard.selecKind();
    }
  };
}).call(this);
