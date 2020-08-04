class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'

  has_orders %w{most_voted newest oldest}, only: :show

  def answer
    if MemberType.can_vote_polls?(current_user, @question.poll.member_type_ids) && current_user.postal_code =~ /^38|^35/
      answer = @question.answers.find_or_initialize_by(author: current_user)
      token = params[:token]

      answer.answer = params[:answer]
      answer.touch if answer.persisted?
      answer.save!
      answer.record_voter_participation(token)

      audit_info("Votacion: { \"value\": \"#{params[:answer]}\", \"Sexo\": \"#{current_user.gender}\", \"Edad\": \"#{current_user.age}\", \"CodigoPostal\": \"#{current_user.postal_code}\", \"Poll\": \"#{@question.poll.id}\", \"question\": \"#{@question.id}\" }")

      @question.question_answers.where(question_id: @question).each do |question_answer|
        question_answer.set_most_voted
      end

      @answers_by_question_id = { @question.id => params[:answer] }
    else
      audit_error("El usuario con id: #{current_user.id}, CodigoPostal: #{current_user.postal_code}, document_type: #{current_user.document_type} y document_number: #{current_user.document_number} ha tratado de votar sin permiso.")
      @answers_by_question_id = { }
    end
  end

end
