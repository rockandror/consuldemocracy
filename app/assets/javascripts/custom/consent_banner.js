(function() {
  "use strict";
  App.ConsentBanner = {
    trackConsent: function(google_tag_manager_id) {
      document.addEventListener("cookies-eu-acknowledged", function() {
        $.ajax({
          url: "https://www.googletagmanager.com/gtag/js?id=" + google_tag_manager_id,
          dataType: "script",
          success: () => {
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag("js", new Date());
            gtag("consent", {"analytics_storage": "allowed"});
            gtag("config", google_tag_manager_id);
          }
        });
      });
    },
    initialize: function() {
      var google_tag_manager_id = $(".cookies-eu").data("google-tag-manager-id");
      if (google_tag_manager_id) {
        App.ConsentBanner.trackConsent(google_tag_manager_id);
      }
    }
  };
}).call(this);
