namespace :settings do
  desc "Remove deprecated settings"
  task remove_deprecated_settings: :environment do
    ApplicationLogger.new.info "Removing deprecated settings"

    deprecated_keys = [
      "place_name",
      "winner_text",
      "banner-style.banner-style-one",
      "banner-style.banner-style-two",
      "banner-style.banner-style-three",
      "banner-img.banner-img-one",
      "banner-img.banner-img-two",
      "banner-img.banner-img-three",
      "min_age_to_verify",
      "proposal_improvement_path",
      "analytics_url",
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
  end

  desc "Add new settings"
  task add_new_settings: :environment do
    Setting.add_new_settings
  end


  desc "Add new settings"
  task add_stting_mount: :environment do
    Setting.create(:key => "months_to_double_verification", :value => 3)
  end

  task add_youtube_settings: :environment do
    Setting.create(:key => "youtube_connect", :value => "KpgTWGu7ecI")
    Setting.create(:key => "youtube_playlist_connect", :value => "PLhnvwI6F9eqXTZQc1yUGl4GX9s96u1AmK")
  end

  task add_other_proposal_settings: :environment do
    Setting.create(:key => "other_proposal_declaration_1", :value => "Soy el representante legal")
    Setting.create(:key => "other_proposal_declaration_2", :value => "Declaración responsable")
  end

  task add_permit_text_settings: :environment do
    Setting.create(:key => "proposal_permit_text", :value => "Texto especial para propuestas")
  end
end
