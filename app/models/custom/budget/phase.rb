require_dependency Rails.root.join("app", "models", "budget", "phase").to_s

class Budget
  class Phase
    audited
  end
end
