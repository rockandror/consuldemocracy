require_dependency Rails.root.join("app", "models", "organization").to_s

class Organization
  audited on: [:create, :update, :destroy]
end
