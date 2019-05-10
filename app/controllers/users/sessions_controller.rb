class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_recaptcha, only: [:create]

  after_action :after_login, only: :create

  def show_recaptcha
    render json: { recaptcha: show_recaptcha_for?(params[:login]) }
  end

  private

    def check_recaptcha
      if Setting["feature.captcha"] && show_recaptcha_for?(params[:user][:login])
        unless verify_recaptcha
          flash.discard
          redirect_to new_user_session_path, alert: I18n.t("recaptcha.errors.verification_failed")
        end
      end
    end

    def show_recaptcha_for?(login)
      user = User.find_by_username(login) || User.find_by_email(login)
      return false unless user.present?
      user.exceeded_failed_login_attempts?
    end

    def after_sign_in_path_for(resource)
      if false #current_user.poll_officer? && current_user.has_poll_active?
        if current_user.poll_officer.letter_officer?
          new_officing_letter_path
        end
      elsif !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_login
      log_event("login", "successful_login")
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

end
