require_dependency Rails.root.join("app", "models", "signature").to_s

class Signature
  audited
end
