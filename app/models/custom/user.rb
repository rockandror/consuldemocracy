require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable if Rails.application.config.devise_lockable

  def self.maximum_attempts
    (Tenant.current_secrets.security[:lockable][:maximum_attempts] || 20).to_i
  end

  def self.unlock_in
    (Tenant.current_secrets.security[:lockable][:unlock_in] || 1).to_i.hours
  end
end
