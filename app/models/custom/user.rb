require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable

  audited on: [:create, :update, :destroy], except: [
    :sign_in_count,
    :last_sign_in_at,
    :current_sign_in_at,
    :locked_at,
    :unlock_token,
    :failed_attempts
  ]

  def self.maximum_attempts
    (Setting["login_attempts_before_lock"].to_i || 2)
  end

  def self.unlock_in
    (Setting["time_to_unlock"].to_i || 2).minutes
  end
end
