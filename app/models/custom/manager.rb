require_dependency Rails.root.join("app", "models", "manager").to_s

class Manager
  audited
end
