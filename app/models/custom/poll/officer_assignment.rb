require_dependency Rails.root.join("app", "models", "poll", "officer_assignment").to_s

class Poll
  class OfficerAssignment
    audited on: [:create, :update, :destroy]
  end
end
