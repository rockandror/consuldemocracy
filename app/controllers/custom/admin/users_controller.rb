require_dependency Rails.root.join("app", "controllers", "admin", "users_controller").to_s

class Admin::UsersController
  def show
  end

  def verify
    now = Time.current
    @user.update!(residence_verified_at: now, verified_at: now, level_two_verified_at: now)
    redirect_to admin_users_path, notice: t("admin.users.verify.notice")
  end
end
