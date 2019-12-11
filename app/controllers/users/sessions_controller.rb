class Users::SessionsController < Devise::SessionsController
  require "ipaddr"
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
        if current_user.ip_out_of_internal_red? && current_user.try(:administrator?)
          if current_user.try(:access_key_tried) > 2 
            sign_out 
            user_blocked_double_confirmations_path
          elsif current_user.phone_number_present?
            double_confimation_needed
          else
            no_phone_double_confirmations_path
          end
        else
          super
        end
      end
    end

    def double_confimation_needed
      unless required_new_password?
        request_access_key_double_confirmations_path
      else
        new_password_sent_double_confirmations_path
      end
    end

    def required_new_password?
      if current_user.access_key_generated_at.present?
        date1= Time.zone.now
        date2= current_user.access_key_generated_at
        (date1.year * 12 + date1.month) - (date2.year * 12 + date2.month) > Setting.find_by(key: "months_to_double_verification").try(:value).to_i
      else
        true
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
