require_dependency Rails.root.join("app", "models", "dashboard", "executed_action").to_s

class Dashboard::ExecutedAction
  audited
end
