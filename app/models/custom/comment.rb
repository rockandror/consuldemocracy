require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment
  audited
end
