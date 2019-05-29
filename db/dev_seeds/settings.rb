section "Creating Settings" do
  Setting.reset_defaults

  {
    "email_domain_for_officials": "madrid.es",
    "facebook_handle": "decidemadrid",
    "feature.human_rights.accepting": "true",
    "feature.human_rights.closed": "true",
    "feature.human_rights.voting": "true",
    "feature.map": "true",
    "feature.probe.plaza": "true",
    "feature.user.skip_verification": "true",
    "mailer_from_address": "noreply@madrid.es",
    "mailer_from_name": "Decide Madrid",
    "meta_description": "Citizen Participation & Open Gov Application",
    "meta_keywords": "citizen participation, open government",
    "meta_title": "Decide Madrid",
    "proposal_notification_minimum_interval_in_days": 0,
    "telegram_handle": "decidemadrid",
    "twitter_handle": "@decidemadrid",
    "url": "http://localhost:3000",
    "verification_offices_url": "http://oficinas-atencion-ciudadano.url/",
    "votes_for_proposal_success": "100",
    "youtube_handle": "decidemadrid"
  }.each do |name, value|
    Setting[name] = value
  end
end
