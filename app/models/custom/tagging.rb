require_dependency Rails.root.join("app", "models", "tagging")

class Tagging
  include Auditable
end
