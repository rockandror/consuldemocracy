namespace :settings do

  desc "Remove deprecated settings"
  task remove_deprecated_settings: :environment do
    ApplicationLogger.new.info "Removing deprecated settings"

    deprecated_keys = [
      "place_name",
      "banner-style.banner-style-one",
      "banner-style.banner-style-two",
      "banner-style.banner-style-three",
      "banner-img.banner-img-one",
      "banner-img.banner-img-two",
      "banner-img.banner-img-three",
      "verification_offices_url",
      "feature.spending_proposals",
      "feature.spending_proposal_features.phase1",
      "feature.spending_proposal_features.phase2",
      "feature.spending_proposal_features.phase3",
      "feature.spending_proposal_features.voting_allowed",
      "feature.spending_proposal_features.final_voting_allowed",
      "feature.spending_proposal_features.open_results_page",
      "feature.spending_proposal_features.valuation_allowed"
    ]

    deprecated_keys.each do |key|
      Setting.where(key: key).first&.destroy
    end
  end

  desc "Rename existing settings"
  task rename_setting_keys: :environment do
    Setting.rename_key from: "map_latitude",  to: "map.latitude"
    Setting.rename_key from: "map_longitude", to: "map.longitude"
    Setting.rename_key from: "map_zoom",      to: "map.zoom"

    Setting.rename_key from: "feature.debates",     to: "process.debates"
    Setting.rename_key from: "feature.proposals",   to: "process.proposals"
    Setting.rename_key from: "feature.polls",       to: "process.polls"
    Setting.rename_key from: "feature.budgets",     to: "process.budgets"
    Setting.rename_key from: "feature.legislation", to: "process.legislation"

    Setting.rename_key from: "per_page_code_head", to: "html.per_page_code_head"
    Setting.rename_key from: "per_page_code_body", to: "html.per_page_code_body"

    Setting.rename_key from: "feature.homepage.widgets.feeds.proposals", to: "homepage.widgets.feeds.proposals"
    Setting.rename_key from: "feature.homepage.widgets.feeds.debates",   to: "homepage.widgets.feeds.debates"
    Setting.rename_key from: "feature.homepage.widgets.feeds.processes", to: "homepage.widgets.feeds.processes"

    Setting.rename_key from: "feature.facebook_login", to: "social.facebook.login"
    Setting.rename_key from: "feature.google_login", to: "social.google.login"
    Setting.rename_key from: "feature.twitter_login", to: "social.twitter.login"
  end

  desc "Add new settings"
  task add_new_settings: :environment do
    Setting.add_new_settings
  end

  desc "Manage settings"
  task manage_settings: [:rename_setting_keys, :add_new_settings]

  desc "Retrocompatibility smtp settings for existing installations"
  task update_smtp_settings: :environment do
    if Rails.application.config.action_mailer.delivery_method == :smtp
      Setting["smtp.address"] = Rails.application.config.action_mailer.smtp_settings[:address]
      Setting["smtp.port"] = Rails.application.config.action_mailer.smtp_settings[:port]
      Setting["smtp.domain"] = Rails.application.config.action_mailer.smtp_settings[:domain]
      Setting["smtp.username"] = Rails.application.config.action_mailer.smtp_settings[:user_name]
      Setting["smtp.password"] = Rails.application.config.action_mailer.smtp_settings[:password]
      Setting["smtp.authentication"] = Rails.application.config.action_mailer.smtp_settings[:authentication]
      Setting["smtp.enable_starttls_auto"] = Rails.application.config.action_mailer.smtp_settings[:enable_starttls_auto]
    end
  end

end
