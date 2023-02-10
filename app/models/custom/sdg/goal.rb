require_dependency Rails.root.join("app", "models", "sdg", "goal").to_s

class SDG::Goal
  audited
end
