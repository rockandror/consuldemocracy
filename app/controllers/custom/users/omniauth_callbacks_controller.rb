require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s

class Users::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :saml

  def saml
    sign_in_with :saml_login, :saml
  end

  private

    alias_method :consul_save_user, :save_user

    def save_user
      if consul_save_user
        if action_name == "saml"
          auth = request.env["omniauth.auth"]
          roles = auth.extra.raw_info.attributes["isMemberOf"] if auth.extra&.raw_info&.attributes
          @user.update_roles(roles)
        end

        true
      end
    end
end
