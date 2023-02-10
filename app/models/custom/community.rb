require_dependency Rails.root.join("app", "models", "community").to_s

class Community
  audited
end
