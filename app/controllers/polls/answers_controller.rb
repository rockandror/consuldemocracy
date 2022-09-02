class Polls::AnswersController < ApplicationController
  authorize_resource :answer, class: "Poll::Answer"

  before_action :load_question

  def delete
    @question.answers.find_by(author: current_user, answer: params[:answer]).destroy!
    render "polls/questions/answers"
  end

  private

    def load_question
      @question = Poll::Question.find_by(id: params[:id])
    end
end
