require_dependency Rails.root.join("app", "models", "legislation", "question").to_s

class Legislation::Question
  audited
end
