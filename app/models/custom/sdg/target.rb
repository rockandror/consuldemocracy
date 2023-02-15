require_dependency Rails.root.join("app", "models", "sdg", "target").to_s

class SDG::Target
  audited
end
