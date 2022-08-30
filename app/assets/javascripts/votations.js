(function() {
  "use strict";
  App.Votations = {
    adjustForm: function() {
      if ($(".votation-type-vote-type").val() === "unique") {
        $(".max-votes").hide();
        $(".description-unique").show();
        $(".description-multiple").hide();
        $(".description-prioritized").hide();
        $(".votation-type-max-votes").attr({ disabled: true });
      } else if ($(".votation-type-vote-type").val() === "multiple") {
        $(".max-votes").show();
        $(".description-unique").hide();
        $(".description-multiple").show();
        $(".description-prioritized").hide();
        $(".votation-type-max-votes").attr({ disabled: false });
      } else {
        $(".max-votes").show();
        $(".description-unique").hide();
        $(".description-multiple").hide();
        $(".description-prioritized").show();
        $(".votation-type-max-votes").attr({ disabled: false });
      }
    },
    initialize: function() {
      $(".votation-type-vote-type").on({
        change: function() {
          App.Votations.adjustForm();
        }
      });
    }
  };
}).call(this);
