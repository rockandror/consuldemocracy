class Admin::SettingsController < Admin::BaseController
  include Admin::ManagesProposalSettings

  helper_method :successful_proposal_setting, :successful_proposals,
                :poll_feature_short_title_setting, :poll_feature_description_setting,
                :poll_feature_link_setting, :email_feature_short_title_setting,
                :email_feature_description_setting,
                :poster_feature_short_title_setting, :poster_feature_description_setting

  def index
    @settings_sections = ["configuration", "process", "feature", "map", "uploads", "proposals", "social"].freeze
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
    redirect_to admin_settings_path, notice: t("admin.settings.index.map.flash.update")
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
    @settings = extract_settings(params[:id])

    render params[:id]
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end

    def content_type_params
      params.permit(:jpg, :png, :gif, :pdf, :doc, :docx, :xls, :xlsx, :csv, :zip)
    end

    def extract_settings(parent_key)
      all_settings = Setting.all.group_by { |setting| setting.type }
      if parent_key == "social"
        [all_settings["social.facebook"]] + [all_settings["social.twitter"]] + [all_settings["social.google"]]
      else
        all_settings[params[:id]]
      end
    end

end
