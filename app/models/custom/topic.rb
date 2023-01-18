require_dependency Rails.root.join("app", "models", "topic").to_s

class Topic
  audited on: [:create, :update, :destroy]
end
