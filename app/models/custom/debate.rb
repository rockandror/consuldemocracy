require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  audited on: [:create, :update, :destroy]
end
