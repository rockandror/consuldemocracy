class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  def config
    Setting.defaults[key]
  end
  delegate :content_type?, :feature?, :group, :text?, to: :config

  def enabled?
    value.present?
  end

  def content_type_group
    key.split(".").second
  end

  class << self
    def [](key)
      where(key: key).pick(:value).presence
    end

    def []=(key, value)
      setting = find_by(key: key) || new(key: key)
      setting.value = value.presence
      setting.save!
    end

    def rename_key(from:, to:)
      if where(key: to).empty?
        value = where(key: from).pick(:value).presence
        create!(key: to, value: value)
      end
      remove(from)
    end

    def remove(key)
      setting = find_by(key: key)
      setting.destroy if setting.present?
    end

    def accepted_content_types_for(group)
      mime_content_types = Setting["uploads.#{group}.content_types"]&.split(" ") || []
      Setting.mime_types[group].select { |_, content_type| mime_content_types.include?(content_type) }.keys
    end

    def mime_types
      {
        "images" => {
          "jpg" => "image/jpeg",
          "png" => "image/png",
          "gif" => "image/gif"
        },
        "documents" => {
          "pdf" => "application/pdf",
          "doc" => "application/msword",
          "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          "xls" => "application/x-ole-storage",
          "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          "csv" => "text/plain",
          "zip" => "application/zip"
        }
      }
    end

    def defaults
      {
        "feature.featured_proposals": Config.new(type: :feature, group: :features),
        "feature.facebook_login": Config.new(true, type: :feature, group: :features),
        "feature.google_login": Config.new(true, type: :feature, group: :features),
        "feature.twitter_login": Config.new(true, type: :feature, group: :features),
        "feature.wordpress_login": Config.new(false, type: :feature, group: :features),
        "feature.public_stats": Config.new(true, type: :feature, group: :features),
        "feature.signature_sheets": Config.new(true, type: :feature, group: :features),
        "feature.user.recommendations": Config.new(true, type: :feature, group: :features),
        "feature.user.recommendations_on_debates": Config.new(true, type: :feature, group: :features),
        "feature.user.recommendations_on_proposals": Config.new(true, type: :feature, group: :features),
        "feature.user.skip_verification": Config.new(true, type: :feature, group: :features),
        "feature.community": Config.new(true, type: :feature, group: :features),
        "feature.map": Config.new(type: :feature, group: :features),
        "feature.allow_attached_documents": Config.new(true, type: :feature, group: :features),
        "feature.allow_images": Config.new(true, type: :feature, group: :features),
        "feature.help_page": Config.new(true, type: :feature, group: :features),
        "feature.remote_translations": Config.new(type: :feature, group: :features),
        "feature.translation_interface": Config.new(type: :feature, group: :features),
        "feature.remote_census": Config.new(type: :feature, group: :features),
        "feature.valuation_comment_notification": Config.new(true, type: :feature, group: :features),
        "feature.graphql_api": Config.new(true, type: :feature, group: :features),
        "feature.sdg": Config.new(true, type: :feature, group: :features),
        "feature.machine_learning": Config.new(false, type: :feature, group: :features),
        "feature.remove_investments_supports": Config.new(true, type: :feature, group: :features),
        "homepage.widgets.feeds.debates": Config.new(true, type: :feature, group: nil),
        "homepage.widgets.feeds.processes": Config.new(true, type: :feature, group: nil),
        "homepage.widgets.feeds.proposals": Config.new(true, type: :feature, group: nil),
        # Code to be included at the top (inside <body>) of every page
        "html.per_page_code_body": Config.new("", group: :html),
        # Code to be included at the top (inside <head>) of every page (useful for tracking)
        "html.per_page_code_head": Config.new("", group: :html),
        "map.latitude": Config.new(51.48, group: :map),
        "map.longitude": Config.new(0.0, group: :map),
        "map.zoom": Config.new(10, group: :map),
        "process.debates": Config.new(true, type: :feature, group: :processes),
        "process.proposals": Config.new(true, type: :feature, group: :processes),
        "process.polls": Config.new(true, type: :feature, group: :processes),
        "process.budgets": Config.new(true, type: :feature, group: :processes),
        "process.legislation": Config.new(true, type: :feature, group: :processes),
        "proposals.successful_proposal_id": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.poll_short_title": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.poll_description": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.poll_link": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.email_short_title": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.email_description": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.poster_short_title": Config.new(type: :text, group: :proposal_dashboard),
        "proposals.poster_description": Config.new(type: :text, group: :proposal_dashboard),
        # Images and Documents
        "uploads.images.title.min_length": Config.new(4, group: :uploads),
        "uploads.images.title.max_length": Config.new(80, group: :uploads),
        "uploads.images.min_width": Config.new(0, group: :uploads),
        "uploads.images.min_height": Config.new(475, group: :uploads),
        "uploads.images.max_size": Config.new(1, group: :uploads),
        "uploads.images.content_types": Config.new("image/jpeg", type: :content_types, group: :uploads),
        "uploads.documents.max_amount": Config.new(3, group: :uploads),
        "uploads.documents.max_size": Config.new(3, group: :uploads),
        "uploads.documents.content_types": Config.new("application/pdf", type: :content_types, group: :uploads),
        # Names for the moderation console, as a hint for moderators
        # to know better how to assign users with official positions
        official_level_1_name: Config.new(I18n.t("seeds.settings.official_level_1_name")),
        official_level_2_name: Config.new(I18n.t("seeds.settings.official_level_2_name")),
        official_level_3_name: Config.new(I18n.t("seeds.settings.official_level_3_name")),
        official_level_4_name: Config.new(I18n.t("seeds.settings.official_level_4_name")),
        official_level_5_name: Config.new(I18n.t("seeds.settings.official_level_5_name")),
        max_ratio_anon_votes_on_debates: Config.new(50),
        max_votes_for_debate_edit: Config.new(1000),
        max_votes_for_proposal_edit: Config.new(1000),
        comments_body_max_length: Config.new(1000),
        proposal_code_prefix: Config.new("CONSUL"),
        votes_for_proposal_success: Config.new(10000),
        months_to_archive_proposals: Config.new(12),
        # Users with this email domain will automatically be marked as level 1 officials
        # Emails under the domain's subdomains will also be included
        email_domain_for_officials: Config.new(""),
        facebook_handle: Config.new(type: :text),
        instagram_handle: Config.new(type: :text),
        telegram_handle: Config.new(type: :text),
        twitter_handle: Config.new(type: :text),
        twitter_hashtag: Config.new(type: :text),
        youtube_handle: Config.new(type: :text),
        org_name: Config.new(default_org_name),
        meta_title: Config.new(type: :text),
        meta_description: Config.new(type: :text),
        meta_keywords: Config.new(type: :text),
        proposal_notification_minimum_interval_in_days: Config.new(3),
        direct_message_max_per_day: Config.new(3),
        mailer_from_name: Config.new(default_org_name),
        mailer_from_address: Config.new(default_mailer_from_address),
        min_age_to_participate: Config.new(16),
        hot_score_period_in_days: Config.new(31),
        related_content_score_threshold: Config.new(-0.3),
        featured_proposals_number: Config.new(3),
        "feature.dashboard.notification_emails": Config.new(type: :feature, group: :features),
        "machine_learning.comments_summary": Config.new(false, type: :feature, group: :machine_learning),
        "machine_learning.related_content": Config.new(false, type: :feature, group: :machine_learning),
        "machine_learning.tags": Config.new(false, type: :feature, group: :machine_learning),
        postal_codes: Config.new(""),
        "remote_census.general.endpoint": Config.new("", group: :remote_census_general),
        "remote_census.request.method_name": Config.new("", group: :remote_census_request),
        "remote_census.request.structure": Config.new("", group: :remote_census_request),
        "remote_census.request.document_type": Config.new("", group: :remote_census_request),
        "remote_census.request.document_number": Config.new("", group: :remote_census_request),
        "remote_census.request.date_of_birth": Config.new("", group: :remote_census_request),
        "remote_census.request.postal_code": Config.new("", group: :remote_census_request),
        "remote_census.response.date_of_birth": Config.new("", group: :remote_census_response),
        "remote_census.response.postal_code": Config.new("", group: :remote_census_response),
        "remote_census.response.district": Config.new("", group: :remote_census_response),
        "remote_census.response.gender": Config.new("", group: :remote_census_response),
        "remote_census.response.name": Config.new("", group: :remote_census_response),
        "remote_census.response.surname": Config.new("", group: :remote_census_response),
        "remote_census.response.valid": Config.new("", group: :remote_census_response),
        "sdg.process.debates": Config.new(true, type: :feature, group: :sdg),
        "sdg.process.proposals": Config.new(true, type: :feature, group: :sdg),
        "sdg.process.polls": Config.new(true, type: :feature, group: :sdg),
        "sdg.process.budgets": Config.new(true, type: :feature, group: :sdg),
        "sdg.process.legislation": Config.new(true, type: :feature, group: :sdg)
      }.with_indifferent_access
    end

    def by_group(group)
      all.select { |setting| setting.group == group }
    end

    def default_org_name
      Tenant.current&.name || default_main_org_name
    end

    def default_main_org_name
      "CONSUL DEMOCRACY"
    end

    def default_mailer_from_address
      "noreply@#{Tenant.current_host.presence || "consuldemocracy.dev"}"
    end

    def reset_defaults
      defaults.each { |name, config| self[name] = config.default_value }
    end

    def add_new_settings
      defaults.each do |name, config|
        self[name] = config.default_value unless find_by(key: name)
      end
    end

    def force_presence_date_of_birth?
      Setting["feature.remote_census"].present? &&
        Setting["remote_census.request.date_of_birth"].present?
    end

    def force_presence_postal_code?
      Setting["feature.remote_census"].present? &&
        Setting["remote_census.request.postal_code"].present?
    end

    def archived_proposals_date_limit
      Setting["months_to_archive_proposals"].to_i.months.ago
    end
  end

  class Config
    attr_reader :default_value, :type, :group

    def initialize(default_value = nil, type: :text, group: :configuration)
      @default_value = default_value
      @type = type
      @group = group
    end

    def content_type?
      type == :content_types
    end

    def feature?
      type == :feature
    end

    def text?
      type == :text
    end
  end
end
