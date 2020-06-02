class Legislation::AnswersController < Legislation::BaseController
  before_action :authenticate_user!
  before_action :verify_resident!

  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process
  load_and_authorize_resource :answer, through: :question

  respond_to :html, :js

  def create
    delete_answers = "delete from legislation_answers where legislation_question_id = #{params[:question_id]} AND user_id = #{current_user.id}"
    ActiveRecord::Base.connection.execute(delete_answers)
    opt = []
    params[:legislation_answer][:legislation_question_option_id].each do |o|
      opt.push(o) if o.to_i != 0
    end
    
    if opt.count >= 1
      if @process.debate_phase.open?
        opt.each do |option|
          ActiveRecord::Base.connection.execute(delete_answers) if params[:legislation_answer][:value_other] != ""
          @answer = Legislation::Answer.new
          @answer.user = current_user
          @answer.question_option = Legislation::QuestionOption.find(option)
          @answer.legislation_question_id = params[:question_id]
          @answer.value_other = params[:legislation_answer][:value_other]
          if @answer.save
            track_event
          else
            puts @answer.errors.full_messages
          end
        end
      end
      redirect_to legislation_process_question_path(@process, @question), notice: "Respuestas guardadas"
    else
      ans = Legislation::Answer.find_by(legislation_question_id: params[:question_id], user_id: current_user.id)
      if !ans.blank?
        ans.legislation_question_option_id = params[:legislation_answer][:legislation_question_option_id]
        ans.save!
        redirect_to legislation_process_question_path(@process, @question), notice: t("legislation.questions.show.answer_question")
      else
        if @process.debate_phase.open?
          @answer.user = current_user
          @answer.save
          track_event
          respond_to do |format|
            format.js
            format.html { redirect_to legislation_process_question_path(@process, @question) }
          end
        else
          alert = t("legislation.questions.participation.phase_not_open")
          respond_to do |format|
            format.js { render json: {}, status: :not_found }
            format.html { redirect_to legislation_process_question_path(@process, @question), alert: alert }
          end
        end
      end
    end
  end

  private

    def answer_params
      params.require(:legislation_answer).permit(
        :value_other, :legislation_question_option_id => []
      )
    end

    def track_event
      ahoy.track "legislation_answer_created".to_sym,
                 "legislation_answer_id": @answer.id,
                 "legislation_question_option_id": @answer.legislation_question_option_id,
                 "legislation_question_id": @answer.legislation_question_id
    end
end
