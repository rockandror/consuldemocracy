class Polls::Answers::PrioritizationListComponent < ApplicationComponent
  attr_reader :question
  delegate :current_user, to: :helpers

  def initialize(question)
    @question = question
  end

  def render?
    question.prioritized? && user_answers.any?
  end

  def user_answers
    question.answers.by_author(current_user.id).order(:order)
  end
end
