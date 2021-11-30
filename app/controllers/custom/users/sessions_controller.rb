require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  prepend_before_action :check_recaptcha, only: [:create]

  def show_recaptcha
    render json: { recaptcha: show_recaptcha_for?(params[:login]) }
  end

  private

    def check_recaptcha
      if show_recaptcha_for?(params[:user][:login])
        return if verify_recaptcha

        self.resource = resource_class.new sign_in_params
        resource.validate

        flash.delete(:recaptcha_error)
        flash.now[:alert] = t("recaptcha.errors.verification_failed")
        render :new
      end
    end

    def show_recaptcha_for?(login)
      user = User.find_by_username(login) || User.find_by_email(login)
      return false unless user.present?
      user.exceeded_failed_login_attempts?
    end
end
