require_dependency Rails.root.join("app/controllers/users/registrations_controller").to_s

class Users::RegistrationsController
  before_action :redirect_to_sign_in, only: [:new]
  before_action :deauthorize_consul_sign_up, only: [:create]
  alias_method :consul_do_finish_signup, :do_finish_signup

  def do_finish_signup
    current_user.assign_attributes(sign_up_params)
    current_user.username = current_user.build_username

    consul_do_finish_signup
  end

  private

    def redirect_to_sign_in
      redirect_to new_user_session_path, status: :moved_permanently
    end

    def deauthorize_consul_sign_up
      raise CanCan::AccessDenied
    end

    def sign_up_params
      params[:user].delete(:redeemable_code) if params[:user].present? && params[:user][:redeemable_code].blank?
      params.require(:user).permit(*allowed_params)
    end

    def consul_allowed_params
      [
        :username, :email, :password,
        :password_confirmation, :terms_of_service, :locale,
        :redeemable_code
      ]
    end

    def allowed_params
      consul_allowed_params + [:first_name, :last_name]
    end
end
