class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  include Translatable
  include DocumentAttributes

  before_action :load_answer, only: [:show, :edit, :update, :documents]

  load_and_authorize_resource :question, class: "::Poll::Question"
  load_and_authorize_resource :answer, class: "::Poll::Question::Answer"

  before_action :authorize_create_answer, only: :create

  def new
    @answer = ::Poll::Question::Answer.new
  end

  def create
    @answer = ::Poll::Question::Answer.new(answer_params)
    @question = @answer.question

    if @answer.save
      redirect_to admin_question_path(@question),
               notice: t("flash.actions.create.poll_question_answer")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @answer.update(answer_params)
      redirect_to admin_question_path(@answer.question),
               notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    if @answer.destroy
      notice = t("admin.answers.destroy.success_notice")
    else
      notice = t("flash.actions.destroy.error")
    end
    redirect_to admin_question_path(@answer.question), notice: notice
  end

  def documents
    @documents = @answer.documents

    render "admin/poll/questions/answers/documents"
  end

  def order_answers
    ::Poll::Question::Answer.order_answers(params[:ordered_list])
    head :ok
  end

  private

    def answer_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      attributes = [:title, :description, :given_order, :question_id,
                    documents_attributes: document_attributes]

      [*attributes, translation_params(Poll::Question::Answer)]
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:id] || params[:answer_id])
    end

    def resource
      load_answer unless @answer
      @answer
    end

    def authorize_create_answer
      question = Poll::Question.find_by id: answer_params[:question_id]
      if question.present? && question.poll.avoid_update?
        redirect_to admin_question_path(question), alert: t("unauthorized.create.poll/question/answer")
      end
    end
end
