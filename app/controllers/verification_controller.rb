class VerificationController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_lock

  skip_authorization_check

  def show
    redirect_to next_step_path[:path], notice: next_step_path[:notice]
  end

  private

    def next_step_path(user = current_user)
      if Setting["feature.custom_verification_process"].present?
        verification_process_next_step(user)
      else
        verification_legacy_next_step(user)
      end
    end

    def verification_legacy_next_step(user)
      if user.organization?
        { path: account_path }
      elsif user.level_three_verified?
        { path: account_path, notice: t("verification.redirect_notices.already_verified") }
      elsif user.verification_letter_sent?
        { path: edit_letter_path }
      elsif user.level_two_verified?
        { path: new_letter_path }
      elsif user.verification_sms_sent?
        { path: edit_sms_path }
      elsif user.verification_email_sent?
        { path: verified_user_path, notice: t("verification.redirect_notices.email_already_sent") }
      elsif user.residence_verified?
        { path: verified_user_path }
      else
        { path: new_residence_path }
      end
    end

    def verification_process_next_step(user)
      if user.residence_verified?
        { path: account_path, notice: flash[:notice] }
      #TODO: Si hay códigos pendientes de introducir mostrar la página de introducción de códigos de confirmación
      else
        { path: new_verification_process_path }
      end
    end
end
