require_dependency Rails.root.join("app", "models", "activity").to_s

class Activity
  audited
end
