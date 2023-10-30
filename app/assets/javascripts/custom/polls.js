(function() {
  "use strict";
  App.Polls = {
    text_input_listener: function() {
      $(document).on("input", ".text-input-form textarea", function(event) {
        let submitButton = $(event.target).next();
        if (submitButton.hasClass("answered")) {
          submitButton.removeClass("answered");
          submitButton.addClass("secondary hollow");
          submitButton.val("Enviar");
        }
      });
    },
    initialize: function() {
      $(".zoom-link").on("click", function(event) {
        var answer;
        answer = $(event.target).closest("div.answer");

        if ($(answer).hasClass("medium-6")) {
          $(answer).removeClass("medium-6");
          $(answer).addClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertBefore($(answer).prev("div.answer"));
          }
        } else {
          $(answer).addClass("medium-6");
          $(answer).removeClass("answer-divider");
          if (!$(answer).hasClass("first")) {
            $(answer).insertAfter($(answer).next("div.answer"));
          }
        }
      });
      App.Polls.text_input_listener();
    },
  };
}).call(this);
