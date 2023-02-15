require_dependency Rails.root.join("app", "models", "poll", "ballot").to_s

class Poll::Ballot
  audited
end
