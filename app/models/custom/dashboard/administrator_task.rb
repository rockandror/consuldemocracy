require_dependency Rails.root.join("app", "models", "dashboard", "administrator_task").to_s

class Dashboard::AdministratorTask
  audited
end
