(function() {
  "use strict";
  App.VerificationHandlerFieldAssignments = {
    initVerificationField: function() {
      var select = $("#verification_field_assignment_verification_field_id")
      var optionSelected = $("option:selected", select);

      if ($(optionSelected).data("field-kind") == "date"){
        $("#js-verification-handler-field-assigment-format").show()
      } else {
        $("#js-verification-handler-field-assigment-format").hide()
      }
    },

    selectVerificationField: function() {
      $("#verification_field_assignment_verification_field_id").on("change", function() {
        var optionSelected = $("option:selected", this);

        if ($(optionSelected).data("field-kind") == "date"){
          $("#js-verification-handler-field-assigment-format").show()
        } else {
          $("#js-verification-handler-field-assigment-format").hide()
        }
      });
    },

    initialize: function() {
      App.VerificationHandlerFieldAssignments.initVerificationField();
      App.VerificationHandlerFieldAssignments.selectVerificationField();
    }
  };
}).call(this);
