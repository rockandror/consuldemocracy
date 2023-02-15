require_dependency Rails.root.join("app", "models", "sdg", "manager").to_s

class SDG::Manager
  audited on: [:create, :update, :destroy]
end
