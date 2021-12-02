require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  include Recaptchable

  prepend_before_action :check_captcha, only: [:create],
                                        if: -> { show_recaptcha_for?(params[:user][:login]) }

  def show_recaptcha
    render json: { recaptcha: show_recaptcha_for?(params[:login]) }
  end

  private

    def show_recaptcha_for?(login)
      user = User.find_by_username(login) || User.find_by_email(login)
      return false unless user.present?
      user.exceeded_failed_login_attempts?
    end
end
