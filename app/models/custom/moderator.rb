require_dependency Rails.root.join("app", "models", "moderator").to_s

class Moderator
  audited on: [:create, :update, :destroy]
end
