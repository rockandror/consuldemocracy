require_dependency Rails.root.join("app", "models", "setting").to_s

unless Rails.env.test?
  class Setting
    class << self
      alias_method :consul_defaults, :defaults

      def defaults
        consul_defaults.merge({
          "org_name": "PvdA",
          "url": "https://pvda.nl",
          "proposal_code_prefix": "MOTIE",
          "max_votes_for_proposal_edit": 1,
          "facebook_handle": nil,
          "instagram_handle": nil,
          "telegram_handle": false,
          "twitter_handle": nil,
          "twitter_hashtag": nil,
          "youtube_handle": nil,
          "feature.wordpress_login": true,
          "feature.facebook_login": false,
          "feature.google_login": false,
          "feature.twitter_login": false,
          "feature.signature_sheets": false,
          "feature.community": false,
          "feature.map": false,
          "feature.remote_census": false,
          "feature.remote_translations": false,
          "feature.translation_interface": false,
          "votes_for_proposal_success": 100,
          "months_to_archive_proposals": 1,
          "mailer_from_address": "noreply@pvda.nl",
          "featured_proposals_number": 3,
          "process.polls": false,
          "process.budgets": false,
        })
      end
    end
  end
end
