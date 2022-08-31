class Polls::QuestionComponent < ApplicationComponent
  attr_reader :question
  delegate :dom_id, to: :helpers

  def initialize(question:)
    @question = question
  end
end
