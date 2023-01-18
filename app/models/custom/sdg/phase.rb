require_dependency Rails.root.join("app", "models", "sdg", "phase").to_s

class SDG::Phase
  audited on: [:create, :update, :destroy]
end
