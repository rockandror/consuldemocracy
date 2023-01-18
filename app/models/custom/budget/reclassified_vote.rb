require_dependency Rails.root.join("app", "models", "budget", "reclassified_vote").to_s

class Budget
  class ReclassifiedVote
    audited on: [:create, :update, :destroy]
  end
end
