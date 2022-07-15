require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  include Recaptchable

  prepend_before_action :check_captcha, only: [:create],
                                        if: -> { show_recaptcha_for?(params[:user][:login]) }

  before_action :set_current_time
  after_action :unify_response_time, only: [:create, :new]

  def show_recaptcha
    render json: { recaptcha: show_recaptcha_for?(params[:login]) }
  end

  private

    def show_recaptcha_for?(login)
      user = User.find_by_username(login) || User.find_by_email(login)
      return false unless user.present?
      user.exceeded_failed_login_attempts?
    end

    def set_current_time
      @@current_time = Time.now
    end

    def unify_response_time
      sleep(1) until Time.now > @@current_time + 5.seconds
    end
end
