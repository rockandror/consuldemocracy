require_dependency Rails.root.join("app", "models", "poll", "booth").to_s

class Poll
  class Booth
    audited
  end
end
