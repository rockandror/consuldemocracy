class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question

  def initialize(question:)
    @question = question
  end

  def answers_read_more_links
    question.answers_with_read_more.map do |answer|
      link_to answer.title, "#answer_#{answer.id}"
    end.join(", ")
  end
end
