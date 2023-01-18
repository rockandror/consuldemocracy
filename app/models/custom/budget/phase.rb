require_dependency Rails.root.join("app", "models", "budget", "phase").to_s

class Budget
  class Phase
    audited on: [:create, :update, :destroy]
  end
end
