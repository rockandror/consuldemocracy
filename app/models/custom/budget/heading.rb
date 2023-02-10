require_dependency Rails.root.join("app", "models", "budget", "heading").to_s

class Budget
  class Heading
    audited
  end
end
