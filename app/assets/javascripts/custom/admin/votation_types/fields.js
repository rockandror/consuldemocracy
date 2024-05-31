(function() {
  "use strict";
  App.AdminVotationTypesFields = {
    adjustForm: function() {
      if ($(this).val() === "unique") {
        $(".max-votes").hide();
        $(".description-unique").show();
        $(".description-multiple").hide();
        $(".description-open").hide();
        $(".description-info").hide();
        $(".votation-type-max-votes").prop("disabled", true);
        return
      } 
      if ($(this).val() === "multiple") {
        $(".max-votes").show();
        $(".description-unique").hide();
        $(".description-multiple").show();
        $(".description-open").hide();
        $(".description-info").hide();
        $(".votation-type-max-votes").prop("disabled", false);
        return
      }
      if ($(this).val() === "open") {
        $(".max-votes").hide();
        $(".description-unique").hide();
        $(".description-multiple").hide();
        $(".description-open").show();
        $(".description-info").hide();
        $(".votation-type-max-votes").prop("disabled", true);
        return
      }
      if ($(this).val().startsWith("info_")) {
        $(".max-votes").hide();
        $(".description-unique").hide();
        $(".description-multiple").hide();
        $(".description-open").hide();
        $(".description-info").show();
        $(".votation-type-max-votes").prop("disabled", true);
        return
      }
    },
    initialize: function() {
      $(".votation-type-vote-type").on("change", App.AdminVotationTypesFields.adjustForm).trigger("change");
    }
  };
}).call(this);
