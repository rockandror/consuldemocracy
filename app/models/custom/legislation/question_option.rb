require_dependency Rails.root.join("app", "models", "legislation", "question_option").to_s

class Legislation::QuestionOption
  audited
end
