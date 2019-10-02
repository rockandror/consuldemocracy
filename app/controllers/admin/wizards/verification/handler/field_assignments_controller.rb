class Admin::Wizards::Verification::Handler::FieldAssignmentsController < Admin::Verification::BaseController
  layout "wizard"
  authorize_resource class: "Verification::Handler::FieldAssignment"
  before_action :set_handler
  before_action :set_field_assignment, only: [:edit, :update, :destroy]

  def index
    @field_assignments = Verification::Handler::FieldAssignment.where(handler: @handler)
  end

  def new
    @field_assignment = Verification::Handler::FieldAssignment.new handler: @handler
  end

  def create
    @field_assignment = Verification::Handler::FieldAssignment.new field_assignment_params
    if @field_assignment.save
      notice = t("admin.wizards.verification.handler.create.notice")
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
      notice = t("admin.wizards.verification.handler.update.notice")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @field_assignment.destroy
      notice = t("admin.wizards.verification.handler.destroy.notice")
      redirect_to admin_wizards_verification_handler_field_assignments_path(@handler),
        notice: notice
    else
      alert = t("admin.wizards.verification.handler.destroy.alert")
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
      params.require(:verification_handler_field_assignment).permit(:verification_field_id).
        merge(handler: @handler)
    end
end
