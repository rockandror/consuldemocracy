require_dependency Rails.root.join('app', 'models', 'user').to_s

class User
  devise :lockable, :session_limitable

  class << self
    alias_method :consul_first_or_initialize_for_oauth, :first_or_initialize_for_oauth

    def first_or_initialize_for_oauth(auth)
      consul_first_or_initialize_for_oauth(auth).tap do |user|
        if user.password.present?
          user.password += rand(0..9).to_s + ("a".."z").to_a.sample + ("A".."Z").to_a.sample
        end
      end
    end
  end

  def exceeded_failed_login_attempts?
    failed_attempts >= 1
  end

  def update_roles(roles_info)
    return if roles_info.nil?

    roles = roles_info.map { |role_info| role_info.match(/gaut_(.+)_ecociv/)&.captures&.first }

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
end
