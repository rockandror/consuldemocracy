require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable if Rails.application.config.devise_lockable

  GENDER = %w[male female other].freeze

  validates :gender, inclusion: { in: GENDER }, allow_blank: true

  scope :other_gender,   -> { where(gender: "other") }

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

  def self.password_complexity
    if Tenant.current_secrets.dig(:security, :password_complexity)
      { digit: 1, lower: 1, symbol: 0, upper: 1 }
    else
      { digit: 0, lower: 0, symbol: 0, upper: 0 }
    end
  end
end
