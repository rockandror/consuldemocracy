require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s

class Users::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml

  def saml
    sign_in_with :saml_login, :saml
  end
end
