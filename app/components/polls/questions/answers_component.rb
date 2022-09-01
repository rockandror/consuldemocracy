class Polls::Questions::AnswersComponent < ApplicationComponent
  attr_reader :question
  delegate :can?, :current_user, :user_signed_in?, to: :helpers

  def initialize(question)
    @question = question
  end

  def already_answered?(answer)
    user_answers.find_by(answer: answer.title).present?
  end

  def voted_before_sign_in?
    user_answers.any? do |vote|
      vote.updated_at < current_user.current_sign_in_at
    end
  end

  def question_answers
    question.question_answers
  end

  def user_answers
    @user_answers ||= question.answers.by_author(current_user.id)
  end
end
