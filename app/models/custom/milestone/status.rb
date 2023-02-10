require_dependency Rails.root.join("app", "models", "milestone", "status").to_s

class Milestone::Status
  audited
end
