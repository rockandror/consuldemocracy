require_dependency Rails.root.join('app', 'models', 'user').to_s

class User
  devise :lockable, :session_limitable

  def exceeded_failed_login_attempts?
    failed_attempts >= 1
  end

  def update_roles(roles_info)
    return if roles_info.nil?

    roles = roles_info.map { |role_info| role_info.match(/gaut_(.+)_ecociv/)[1] }

    if roles.include?("admin")
      create_administrator! unless administrator?
    else
      administrator&.destroy!
    end

    if roles.include?("moderadores")
      create_moderator! unless moderator?
    else
      moderator&.destroy!
    end

    if roles.include?("gestores")
      create_manager! unless manager?
    else
      manager&.destroy!
    end
  end

  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_email_confirmed = oauth_email.present? && (auth.info.verified || auth.info.verified_email)
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_user || User.new(
      username:  auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token.insert(rand(1..20), rand(0..9).to_s),
      terms_of_service: '1',
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil
    )
  end
end
