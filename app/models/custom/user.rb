require_dependency Rails.root.join('app', 'models', 'user').to_s

class User
  devise :lockable

  def exceeded_failed_login_attempts?
    failed_attempts >= 1
  end
end
