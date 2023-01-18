require_dependency Rails.root.join("app", "models", "poll", "recount").to_s

class Poll::Recount
  audited on: [:create, :update, :destroy]
end
