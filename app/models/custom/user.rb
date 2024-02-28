require_dependency Rails.root.join("app", "models", "user").to_s

class User
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
end
