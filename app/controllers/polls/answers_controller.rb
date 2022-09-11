class Polls::AnswersController < ApplicationController
  authorize_resource :answer, class: "Poll::Answer"

  before_action :load_question

  def delete
    @answer = @question.answers.find_by(author: current_user, answer: params[:answer])
    @answer.destroy_and_remove_voter_participation

    respond_to do |format|
      format.html do
        redirect_to request.referer
      end
      format.js do
        render "polls/questions/answers"
      end
    end
  end

  private

    def load_question
      @question = Poll::Question.find_by(id: params[:id])
    end
end
