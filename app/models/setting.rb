class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  def type
    prefix = key.split(".").first
    if %w[feature process proposals map html homepage].include? prefix
      prefix
    else
      "configuration"
    end
  end

  def enabled?
    value.present?
  end

  class << self
    def [](key)
      where(key: key).pluck(:value).first.presence
    end

    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value.presence
      setting.save!
      value
    end

    def rename_key(from:, to:)
      if where(key: to).empty?
        value = where(key: from).pluck(:value).first.presence
        create!(key: to, value: value)
      end
      remove(from)
    end

    def remove(key)
      setting = where(key: key).first
      setting.destroy if setting.present?
    end

    def defaults
      {
        "blog_url": "https://diario.madrid.es/decidemadrid/",
        "captcha.max_failed_login_attempts": 5,
        "comments_body_max_length": 1000,
        "dashboard.emails": nil,
        "direct_message_max_per_day": 3, # For proposal notifications
        # Users with this email domain will automatically be marked as level 1 officials
        # Emails under the domain's subdomains will also be included
        "email_domain_for_officials": "",
        "facebook_handle": "Abriendo-Madrid-1475577616080350",
        "feature.allow_attached_documents": true,
        "feature.allow_images": true,
        "feature.captcha": nil,
        "feature.community": true,
        "feature.facebook_login": true,
        "feature.featured_proposals": nil,
        "feature.google_login": true,
        "feature.guides": true,
        "feature.help_page": true,
        "feature.map": nil,
        "feature.public_stats": true,
        "feature.signature_sheets": true,
        "feature.twitter_login": true,
        "feature.user.recommendations": true,
        "feature.user.recommendations_on_debates": true,
        "feature.user.recommendations_on_proposals": true,
        "feature.user.skip_verification": true,
        "featured_proposals_number": 3,
        "homepage.widgets.feeds.debates": true,
        "homepage.widgets.feeds.processes": true,
        "homepage.widgets.feeds.proposals": true,
        "hot_score_period_in_days": 31,
        # Code to be included at the top (inside <body>) of every page
        "html.per_page_code_body": "",
        # Code to be included at the top (inside <head>) of every page (useful for tracking)
        "html.per_page_code_head": "",
        "instagram_handle": "decidemadrid",
        "mailer_from_address": "noreply@consul.dev",
        "mailer_from_name": "CONSUL",
        "map.latitude": 40.4332002,
        "map.longitude": -3.7009591,
        "map.zoom": 10,
        "max_ratio_anon_votes_on_debates": 50,
        "max_votes_for_debate_edit": 1000,
        "max_votes_for_proposal_edit": 1000,
        "meta_description": nil,
        "meta_keywords": nil,
        "meta_title": nil,
        "min_age_to_participate": 16,
        "months_to_archive_proposals": 12,
        # Names for the moderation console, as a hint for moderators
        # to know better how to assign users with official positions
        "official_level_1_name": "Empleados públicos",
        "official_level_2_name": "Organización Municipal",
        "official_level_3_name": "Directores generales",
        "official_level_4_name": "Concejales",
        "official_level_5_name": "Alcaldesa",
        "opendata_url": "http://datos.madrid.es/",
        "org_name": "Decide Madrid", # Consul installation's organization name
        "process.budgets": true,
        "process.debates": true,
        "process.legislation": true,
        "process.polls": true,
        "process.proposals": true,
        "proposal_code_prefix": "MAD",
        "proposal_notification_minimum_interval_in_days": 3,
        "proposals.email_description": nil,
        "proposals.email_short_title": nil,
        "proposals.poll_description": nil,
        "proposals.poll_link": nil,
        "proposals.poll_short_title": nil,
        "proposals.poster_description": nil,
        "proposals.poster_short_title": nil,
        "proposals.successful_proposal_id": nil,
        "related_content_score_threshold": -0.3,
        "telegram_handle": nil,
        "transparency_url": "http://transparencia.madrid.es/",
        "twitter_handle": "abriendomadrid",
        "twitter_hashtag": "#decidemadrid",
        "url": "https://decide.madrid.es", # Public-facing URL of the app.
        "verification_offices_url": "http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD",
        "votes_for_proposal_success": 53726,
        "youtube_handle": "channel/UCFmaChI9quIY7lwHplnacfg"
      }
    end

    def reset_defaults
      defaults.each { |name, value| self[name] = value }
    end
  end
end
