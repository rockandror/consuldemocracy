class Admin::AuditsController < Admin::BaseController
  load_and_authorize_resource

  before_action :is_audit_enabled?

  def index
    @audits = @audits.order(created_at: :desc).page(params[:page])
  end

  private

    def is_audit_enabled?
      unless Rails.application.config.auditing_enabled
        redirect_to admin_root_path, notice: t("admin.audits.disabled_feature")
      end
    end
end
