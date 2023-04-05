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
    (Setting["login_attempts_before_lock"] || 2).to_i
  end

  def self.unlock_in
    (Setting["time_to_unlock"] || 2).to_i.minutes
  end
end
