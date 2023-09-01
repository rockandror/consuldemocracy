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

    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      consul_allowed_params + [:date_of_birth, :geozone_id, :gender]
    end
end
