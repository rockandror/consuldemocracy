require_dependency Rails.root.join("app", "models", "poll", "booth_assignment").to_s

class Poll
  class BoothAssignment
    audited
  end
end
