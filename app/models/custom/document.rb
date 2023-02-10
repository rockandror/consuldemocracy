require_dependency Rails.root.join("app", "models", "document").to_s

class Document
  audited
end
