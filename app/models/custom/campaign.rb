require_dependency Rails.root.join("app", "models", "campaign").to_s

class Campaign
  audited on: [:create, :update, :destroy]
end
