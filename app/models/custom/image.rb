require_dependency Rails.root.join("app", "models", "image").to_s

class Image
  audited
end
