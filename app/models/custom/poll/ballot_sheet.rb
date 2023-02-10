require_dependency Rails.root.join("app", "models", "poll", "ballot_sheet").to_s

class Poll::BallotSheet
  audited
end
