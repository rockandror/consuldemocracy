require_dependency Rails.root.join("app", "models", "manager").to_s

class Manager
  audited on: [:create, :update, :destroy]
end
