require_dependency Rails.root.join("app/models/user").to_s

class User
  def postpone_email_change?
    false
  end

  def send_oauth_confirmation_instructions
    update(oauth_email: nil) if oauth_email.present?
  end

  class << self
    alias_method :consul_first_or_initialize_for_oauth, :first_or_initialize_for_oauth

    def first_or_initialize_for_oauth(auth)
      user = consul_first_or_initialize_for_oauth(auth)

      user.tap do
        if user.new_record?
          user.confirmed_at = DateTime.current
        end
      end
    end
  end
end
