require_dependency Rails.root.join("app", "models", "poll", "question").to_s

class Poll::Question
  audited
end
