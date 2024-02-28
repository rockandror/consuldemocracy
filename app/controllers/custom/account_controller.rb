require_dependency Rails.root.join("app", "controllers", "account_controller").to_s

class AccountController
  private

    alias_method :consul_allowed_params, :allowed_params

    def allowed_params
      if @account.organization?
        consul_allowed_params
      else
        consul_allowed_params + [:date_of_birth, :geozone_id, :gender]
      end
    end
end
