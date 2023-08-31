require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable if Rails.application.config.devise_lockable

  audited except: [
    :sign_in_count,
    :last_sign_in_at,
    :current_sign_in_at,
    :locked_at,
    :unlock_token,
    :failed_attempts
  ]

  def self.maximum_attempts
    (Tenant.current_secrets.dig(:security, :lockable, :maximum_attempts) || 5).to_i
  end

  def self.unlock_in
    (Tenant.current_secrets.dig(:security, :lockable, :unlock_in) || 0.5).to_f.hours
  end
end
