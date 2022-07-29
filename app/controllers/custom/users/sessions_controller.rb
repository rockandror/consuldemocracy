require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  include Recaptchable

  prepend_before_action :check_captcha, only: [:create]

  alias_method :consul_create, :create
  alias_method :consul_after_sign_out_path_for, :after_sign_out_path_for

  def create
    sleep rand(0.0..0.5)
    consul_create
  end

  def destroy
    # Preserve the saml_uid and saml_session_index in the session
    saml_uid = session["saml_uid"]
    saml_session_index = session["saml_session_index"]
    super do
      session["saml_uid"] = saml_uid
      session["saml_session_index"] = saml_session_index
    end
  end

  private

    def after_sign_out_path_for(resource)
      saml_settings = Devise.omniauth_configs[:saml]
      if session["saml_uid"] && session["saml_session_index"] &&
        saml_settings&.options[:idp_slo_service_url]
        user_saml_omniauth_authorize_path + "/spslo"
      else
        consul_after_sign_out_path_for(resource)
      end
    end
end
