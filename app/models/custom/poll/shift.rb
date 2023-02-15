require_dependency Rails.root.join("app", "models", "poll", "shift").to_s

class Poll
  class Shift
    audited on: [:create, :update, :destroy]
  end
end
