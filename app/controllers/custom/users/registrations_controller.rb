require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController
  after_action :track_activity, only: :create

  private

    def track_activity
      if resource.persisted?
        ActivityLog.create!(activity: "register", result: "ok", payload: resource.email)
      else
        ActivityLog.create!(activity: "register", result: "error", payload: resource.errors.full_messages)
      end
    end

    def allowed_params
      [
        :username, :gender, :date_of_birth, :location, :email, :password,
        :password_confirmation, :terms_of_service, :locale,
        :redeemable_code
      ]
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email, :gender, :date_of_birth, :location])
    end
end
