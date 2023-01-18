require_dependency Rails.root.join("app", "models", "poll", "officer").to_s

class Poll
  class Officer
    audited on: [:create, :update, :destroy]
  end
end
