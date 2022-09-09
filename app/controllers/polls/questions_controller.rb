class Polls::QuestionsController < ApplicationController
  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w[most_voted newest oldest], only: :show

  def answer
    answer = @question.find_or_initialize_user_answer(current_user, params[:answer])
    answer.answer = params[:answer]
    answer.save_and_record_voter_participation

    respond_by_format
  end

  def prioritize_answers
    if params[:ordered_list].present?
      params[:ordered_list].each_with_index do |title, i|
        @question.answers.by_author(current_user.id).find_by(answer: title).update(order: i + 1)
      end
    end

    respond_by_format
  end

  private

    def respond_by_format
      respond_to do |format|
        format.html do
          redirect_to request.referer
        end
        format.js do
          render :answers
        end
      end
    end
end
