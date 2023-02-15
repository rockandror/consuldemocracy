require_dependency Rails.root.join("app", "models", "poll", "partial_result").to_s

class Poll::PartialResult
  audited
end
