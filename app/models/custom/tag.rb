require_dependency Rails.root.join("app", "models", "tag")

class Tag
  include Auditable
end
