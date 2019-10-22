class Admin::Wizards::Verification::Handler::FieldAssignmentsController < Admin::Wizards::BaseController
  authorize_resource class: "Verification::Handler::FieldAssignment"
  before_action :set_handler
  before_action :set_field_assignment, only: [:edit, :update, :destroy]

  def index
    @field_assignments = Verification::Handler::FieldAssignment.where(handler: @handler)
    @settings = settings_by_handler(@handler)
  end

  def new
    @field_assignment = Verification::Handler::FieldAssignment.new handler: @handler
  end

  def create
    @field_assignment = Verification::Handler::FieldAssignment.new field_assignment_params
    if @field_assignment.save
      notice = t("admin.wizards.verification.handler.field_assignments.create.notice")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        notice: notice
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @field_assignment.update(field_assignment_params)
      notice = t("admin.wizards.verification.handler.field_assignments.update.notice")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @field_assignment.destroy
      notice = t("admin.wizards.verification.handler.field_assignments.destroy.notice")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        notice: notice
    else
      alert = t("admin.wizards.verification.handler.field_assignments.destroy.alert")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        alert: alert
    end
  end

  private

    def set_handler
      @handler = params[:handler_id]
    end

    def set_field_assignment
      @field_assignment = Verification::Handler::FieldAssignment.find(params[:id])
    end

    def field_assignment_params
      attributes = [:format, :request_path, :response_path, :verification_field_id]

      params.require(:verification_handler_field_assignment).permit(attributes).merge(handler: @handler)
    end

    def settings_by_handler(handler)
      case handler
      when "remote_census"
        remote_census_settings
      when "sms"
        sms_settings
      end
    end

    def remote_census_settings
      [Setting.find_by(key: "verification_remote_census.general.endpoint"),
       Setting.find_by(key: "verification_remote_census.request.method_name"),
       Setting.find_by(key: "verification_remote_census.request.structure"),
       Setting.find_by(key: "verification_remote_census.response.valid")]
    end

    def sms_settings
      all_settings = Setting.all.group_by { |setting| setting.type }
      all_settings["sms"]
    end
end
