require_dependency Rails.root.join("app", "models", "poll", "voter").to_s

class Poll
  class Voter
    audited on: [:create, :update, :destroy]
  end
end
