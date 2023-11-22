class Admin::SettingsController < Admin::BaseController
  def index
    @configuration_settings = Setting.by_group(:configuration)
    @feature_settings = Setting.by_group(:features)
    @participation_processes_settings = Setting.by_group(:processes)
    @map_configuration_settings = Setting.by_group(:map)
    @proposals_settings = Setting.by_group(:proposal_dashboard)
    @remote_census_general_settings = Setting.by_group(:remote_census_general)
    @remote_census_request_settings = Setting.by_group(:remote_census_request)
    @remote_census_response_settings = Setting.by_group(:remote_census_response)
    @uploads_settings = Setting.by_group(:uploads)
    @sdg_settings = Setting.by_group(:sdg)
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update!(settings_params)

    respond_to do |format|
      format.html { redirect_to request_referer, notice: t("admin.settings.flash.updated") }
      format.js
    end
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
    setting.update! value: mime_type_values.join(" ")
    redirect_to admin_settings_path, notice: t("admin.settings.flash.updated")
  end

  private

    def settings_params
      params.require(:setting).permit(allowed_params)
    end

    def allowed_params
      [:value]
    end

    def content_type_params
      params.permit(:jpg, :png, :gif, :pdf, :doc, :docx, :xls, :xlsx, :csv, :zip)
    end

    def request_referer
      return request.referer + params[:setting][:tab] if params[:setting][:tab]

      request.referer
    end
end
