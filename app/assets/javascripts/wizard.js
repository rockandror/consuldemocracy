(function() {
  "use strict";
  App.Wizard = {
    selecKind: function() {
      $("#verification_field_kind").on("change", function() {
        var selected = $(this).find(":selected").val();
        console.log(selected)
        var checkBoxLink = $("#input-checkbox-link");
        var fieldVerificationOptionsSection = $("#field-verification-options-section");
        if (selected == "checkbox") {
          fieldVerificationOptionsSection.hide();
          checkBoxLink.show();
        } else if (selected == "selector") {
          checkBoxLink.hide();
          fieldVerificationOptionsSection.show();
        } else {
          checkBoxLink.hide();
          fieldVerificationOptionsSection.hide();
        }
      });
    },
    initialize: function() {
      App.Wizard.selecKind();
    }
  };
}).call(this);
