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
end
