require_dependency Rails.root.join("app", "models", "budget", "heading").to_s

class Budget
  class Heading
    audited on: [:create, :update, :destroy]
  end
end
