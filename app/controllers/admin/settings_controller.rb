class Admin::SettingsController < Admin::BaseController
  include Admin::ManagesProposalSettings

  helper_method :successful_proposal_setting, :successful_proposals,
                :poll_feature_short_title_setting, :poll_feature_description_setting,
                :poll_feature_link_setting, :email_feature_short_title_setting,
                :email_feature_description_setting,
                :poster_feature_short_title_setting, :poster_feature_description_setting

  def index
    @settings_groups = ["configuration", "process", "feature", "map", "uploads", "proposals", "remote_census", "social", "advanced", "smtp", "regional", "sms"].freeze
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update(settings_params)
    redirect_to request.referer, notice: t("admin.settings.flash.updated")
  end

  def update_map
    Setting["map.latitude"] = params[:latitude].to_f
    Setting["map.longitude"] = params[:longitude].to_f
    Setting["map.zoom"] = params[:zoom].to_i
    redirect_to request.referer, notice: t("admin.settings.index.map.flash.update")
  end

  def update_content_types
    setting = Setting.find(params[:id])
    group = setting.content_type_group
    mime_type_values = content_type_params.keys.map do |content_type|
      Setting.mime_types[group][content_type]
    end
    setting.update value: mime_type_values.join(" ")
    redirect_to admin_settings_path, notice: t("admin.settings.flash.updated")
  end

  def show
    @settings = settings_by_group(params[:id])

    render params[:id]
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end

    def content_type_params
      params.permit(:jpg, :png, :gif, :pdf, :doc, :docx, :xls, :xlsx, :csv, :zip)
    end

    def settings_by_group(group)
      all_settings = Setting.all.group_by { |setting| setting.type }
      case group
      when "remote_census"
        [all_settings["remote_census.general"]] + [all_settings["remote_census.request"]] + [all_settings["remote_census.response"]]
      when "social"
        [all_settings["social.facebook"]] + [all_settings["social.twitter"]] + [all_settings["social.google"]]
      when "advanced"
        [all_settings["advanced.auth"]] + [all_settings["advanced.tracking"]]
      when "regional"
        [all_settings["regional.default_locale"]] + [all_settings["regional.available_locale"]] + [all_settings["regional.time_zone"]]
      else
        all_settings[group]
      end
    end

end
