require_dependency Rails.root.join("app", "models", "poll", "answer").to_s

class Poll::Answer
  audited
end
