require_dependency Rails.root.join("app", "models", "poll", "recount").to_s

class Poll::Recount
  audited
end
