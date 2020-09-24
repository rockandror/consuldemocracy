// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-es
//= require jquery-ui/effects/effect-shake
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/sortable
//= require jquery-fileupload/basic
//= require foundation
//= require turbolinks
//= require ckeditor/loader
//= require_directory ./ckeditor
//= require social-share-button
//= require initial
//= require ahoy
//= require app
//= require check_all_none
//= require comments
//= require foundation_extras
//= require ie_alert
//= require location_changer
//= require moderator_comment
//= require moderator_debates
//= require moderator_proposals
//= require moderator_budget_investments
//= require moderator_proposal_notifications
//= require prevent_double_submission
//= require gettext
//= require annotator
//= require tags
//= require users
//= require votes
//= require allow_participation
//= require annotatable
//= require advanced_search
//= require registration_form
//= require suggest
//= require forms
//= require tracks
//= require valuation_budget_investment_form
//= require embed_video
//= require fixed_bar
//= require banners
//= require probe
//= require social_share
//= require checkbox_toggle
//= require markdown-it
//= require markdown_editor
//= require cocoon
//= require answers
//= require questions
//= require legislation_admin
//= require legislation
//= require legislation_allegations
//= require legislation_annotatable
//= require watch_form_changes
//= require followable
//= require flaggable
//= require documentable
//= require imageable
//= require tree_navigator
//= require custom
//= require tag_autocomplete
//= require polls_admin
//= require leaflet
//= require map
//= require polls
//= require sortable
//= require legislation_proposals
//= require table_sortable
//= require investment_report_alert
//= require send_newsletter_alert
//= require managers
//= require globalize
//= require send_admin_notification_alert
//= require settings
//= require login_form

var initialize_modules = function() {
  App.Answers.initialize();
  App.Questions.initialize();
  App.Comments.initialize();
  App.Users.initialize();
  App.Votes.initialize();
  App.AllowParticipation.initialize();
  App.Tags.initialize();
  App.FoundationExtras.initialize();
  App.LocationChanger.initialize();
  App.CheckAllNone.initialize();
  App.PreventDoubleSubmission.initialize();
  App.IeAlert.initialize();
  App.Annotatable.initialize();
  App.AdvancedSearch.initialize();
  App.RegistrationForm.initialize();
  App.Suggest.initialize();
  App.Forms.initialize();
  App.Tracks.initialize();
  App.ValuationBudgetInvestmentForm.initialize();
  App.EmbedVideo.initialize();
  App.FixedBar.initialize();
  App.Banners.initialize();
  App.SocialShare.initialize();
  App.CheckboxToggle.initialize();
  App.MarkdownEditor.initialize();
  App.LegislationAdmin.initialize();
  App.LegislationAllegations.initialize();
  App.Legislation.initialize();
  if ( $(".legislation-annotatable").length )
    App.LegislationAnnotatable.initialize();
  App.WatchFormChanges.initialize();
  App.TreeNavigator.initialize();
  App.Documentable.initialize();
  App.Imageable.initialize();
  App.TagAutocomplete.initialize();
  App.PollsAdmin.initialize();
  App.Map.initialize();
  App.Polls.initialize();
  App.Sortable.initialize();
  App.LegislationProposals.initialize();
  App.TableSortable.initialize();
  App.InvestmentReportAlert.initialize();
  App.SendNewsletterAlert.initialize();
  App.Managers.initialize();
  App.Globalize.initialize();
  App.SendAdminNotificationAlert.initialize();
  App.Settings.initialize();
  App.LoginForm.initialize();
};

$(function(){
  Turbolinks.enableProgressBar();

  $(document).ready(initialize_modules);
  $(document).on("page:load", initialize_modules);
  $(document).on("ajax:complete", initialize_modules);
});

function hide_element(element) {
  var x = document.getElementById(element);
  if (x.style.display === "none") {
    x.style.display = "block";
  } else {
    x.style.display = "none";
  }
}

function hide_checkboxs(element) {
  var x = document.getElementById(element);
  if (x.disabled == false) {
    x.disabled = true;
  } else {
    x.disabled = false;
  }
}

function cleanCommentsForm() {
  document.getElementById("new_comment").reset();
}

function setHidden(limit) {
  count = 0
  $(".checkbox-answer").each(function(){
    if($(this).prop("checked")){
      count = count +1
    }
  });
  $(".checkbox-answer").each(function(){
    if(count >= limit){
      if($(this).prop("checked") == false){
        $(this).attr("disabled", true);
      }else{
        $(this).attr("disabled", false);
      }
    }else{
      $(this).attr("disabled", false);
    }
  });
  if(count >= 1){
    document.getElementById("submit").display = "block";
  }
}

function setHiddenResponse(id) {
  count = 0
  $(".checkbox-answer-"+id).each(function(){
    if($(this).prop("checked")){
      count = count +1
    }
  });
  $(".checkbox-answer-"+id).each(function(){
    if(count >= 1){
      if($(this).prop("checked") == false){
        $(this).attr("disabled", true);
      }else{
        $(this).attr("disabled", false);
      }
    }else{
      $(this).attr("disabled", false);
    }
  });
  if(count >= 1){
    document.getElementById("submit").display = "block";
  }
}
