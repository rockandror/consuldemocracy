require_dependency Rails.root.join("app", "models", "identity").to_s

class Identity
  audited on: [:create, :update, :destroy]
end
