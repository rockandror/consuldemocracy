class Verification::ProcessController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_already_verified_users, only: :new
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
      flash.now[:error] = t("verification.process.create.flash.error")
      render :new
    end
  end

  private

    def process_params
      attributes = Verification::Field.all.pluck(:name)
      confirmation_attributes = confirmation_params
      params.require(:verification_process).permit(attributes, confirmation_attributes)
    end

    def confirmation_params
      Verification::Field.confirmation_validation.map { |field| "#{field.name}_confirmation" }
    end

    def continue
      if @process.requires_confirmation?
        redirect_to new_verification_confirmation_path
      else
        redirect_to verification_path, notice: t("verification.process.create.flash.success")
      end
    end

    def redirect_already_verified_users
      if current_user.residence_verified?
        redirect_to account_path, notice: t("verification.process.create.flash.already_verified")
      end
    end
end
