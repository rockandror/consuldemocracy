require_dependency Rails.root.join("app", "models", "newsletter").to_s

class Newsletter
  audited on: [:create, :update, :destroy]
end
