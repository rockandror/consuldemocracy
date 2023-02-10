require_dependency Rails.root.join("app", "models", "sdg", "local_target").to_s

class SDG::LocalTarget
  audited
end
