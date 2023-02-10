require_dependency Rails.root.join("app", "models", "legislation", "answer").to_s

class Legislation::Answer
  audited
end
