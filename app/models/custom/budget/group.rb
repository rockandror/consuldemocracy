require_dependency Rails.root.join("app", "models", "budget", "group").to_s

class Budget
  class Group
    audited on: [:create, :update, :destroy]
  end
end
