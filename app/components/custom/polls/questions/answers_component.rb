class Polls::Questions::AnswersComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "polls", "questions", "answers_component").to_s


class Polls::Questions::AnswersComponent < ApplicationComponent
  def open_answer
    if question.answers.nil? || question.answers.empty?
      return ""
    end
    question.answers.by_author(current_user).first.answer
  end
end
