require_dependency Rails.root.join("app", "models", "sdg", "relation").to_s

class SDG::Relation
  audited
end
