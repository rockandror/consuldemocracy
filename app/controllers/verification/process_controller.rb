class Verification::ProcessController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_lock
  authorize_resource

  def new
    @process = Verification::Process.new
  end

  def create
    @process = Verification::Process.new(process_params.merge(user: current_user))
    if @process.save
      continue
    else
      flash.now[:error] = t("verification.process.create.error")
      render :new
    end
  end

  private

    def process_params
      params.require(:verification_process).permit(Verification::Field.all.pluck(:name))
    end

    def continue
      if @process.requires_confirmation?
        redirect_to new_verification_confirmation_path,
          notice: t("verification.process.create.flash.success")
      else
        # TODO: Mark current user as verified if all handlers returned successful responses
        redirect_to verified_user_path,
          notice: t("verification.process.create.flash.success")
      end
    end
end
