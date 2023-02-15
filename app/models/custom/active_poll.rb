require_dependency Rails.root.join("app", "models", "active_poll").to_s

class ActivePoll
  audited on: [:create, :update, :destroy]
end
