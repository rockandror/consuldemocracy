require_dependency Rails.root.join("app", "controllers", "budgets_controller").to_s

class BudgetsController
  before_action :authenticate_user!
end
