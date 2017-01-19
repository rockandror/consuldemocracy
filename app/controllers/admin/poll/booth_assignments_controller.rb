class Admin::Poll::BoothAssignmentsController < Admin::BaseController

  def create
    @booth_assignment = ::Poll::BoothAssignment.new(poll_id: booth_assignment_params[:poll], booth_id: booth_assignment_params[:booth])

    if @booth_assignment.save
      notice = t("admin.booth_assignments.flash.create")
    else
      notice = t("admin.booth_assignments.flash.error_create")
    end
    redirect_to admin_poll_path(@booth_assignment.poll_id, anchor: 'tab-booths'), notice: notice
  end

  def destroy
    @booth_assignment = ::Poll::BoothAssignment.find(params[:id])

    if @booth_assignment.destroy
      notice = t("admin.booth_assignments.flash.destroy")
    else
      notice = t("admin.booth_assignments.flash.error_destroy")
    end
    redirect_to admin_poll_path(@booth_assignment.poll_id, anchor: 'tab-booths'), notice: notice
  end

  def show
    @poll = ::Poll.find(params[:poll_id])
    @booth_assignment = @poll.booth_assignments.includes(:recounts, officer_assignments: [officer: [:user]]).find(params[:id])
  end

  private

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find(params[:id])
    end

    def booth_assignment_params
      params.permit(:booth, :poll)
    end

end