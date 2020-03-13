class Sures::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :track_signup, only: :new
  before_action :configure_permitted_parameters

  invisible_captcha only: [:create], honeypot: :address, scope: :user

  def new
    super do |user|
      user.use_redeemable_code = true if params[:use_redeemable_code].present?
    end
  end

  def create
    build_resource(sign_up_params)
    track_event
    if resource.valid?
      log_event("registration", "successful_registration","SURES")
      super
    else
      render :new
    end
  end

  private

    def sign_up_params
      params[:user].delete(:redeemable_code) if params[:user].present? && params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email, :password,
                                   :password_confirmation, :terms_of_service, :locale,
                                   :use_redeemable_code, :redeemable_code)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update).push(:email)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email])
    end

    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end

    def track_event
      if session[:track_signup].present?
        ahoy.track(:clicked_signup_button) rescue nil
      end
    end

    def track_signup
      log_event("registration", "access_registration_form", campaign_name)
    end

    def campaign_name
      session[:campaign_name]
    end
end
