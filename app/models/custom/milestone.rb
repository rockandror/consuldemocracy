require_dependency Rails.root.join("app", "models", "milestone").to_s

class Milestone
  audited
end
