class Admin::AuditsController < Admin::BaseController
  load_and_authorize_resource

  before_action :is_audit_enabled?

  def index
    @audits = @audits.by_class_and_id(*convert_search_param) if params[:search].present?
    @audits = @audits.order(created_at: :desc).page(params[:page])
  end

  def show; end

  private

    def is_audit_enabled?
      unless Rails.application.config.auditing_enabled
        redirect_to admin_root_path, notice: t("admin.audits.disabled_feature")
      end
    end

    def convert_search_param
      return [nil, nil] unless /^[^#]+\#{1}\d+$/.match?(params[:search])

      params[:search].split("#")
    end
end
