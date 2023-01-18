require_dependency Rails.root.join("app", "controllers", "admin", "system_emails_controller").to_s

class Admin::SystemEmailsController
  alias_method :consul_index, :index

  def index
    consul_index
    @system_emails[:contact] = %w[view edit_info]
  end
end
