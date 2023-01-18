require_dependency Rails.root.join("app", "models", "sdg", "target").to_s

class SDG::Target
  audited on: [:create, :update, :destroy]
end
