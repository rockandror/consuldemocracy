require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll
  audited
end
