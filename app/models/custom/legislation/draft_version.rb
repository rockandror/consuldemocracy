require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion
  audited
end
