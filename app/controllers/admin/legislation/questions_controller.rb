class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  include Translatable

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :question, class: "Legislation::Question", through: :process

  def index
    @questions = @process.questions
  end

  def new
  end

  def other_answers
    @question = Legislation::Question.find(params[:question])
    @answers = Legislation::Answer.where("legislation_question_id = ? AND legislation_question_option_id= ? AND value_other is not null AND value_other != ''",params[:question], params[:option])
    #render :other_answers
  end

  def range_answers
    @question = Legislation::Question.find(params[:question])
    @answers = Legislation::Answer.where("legislation_question_id = ? AND legislation_question_option_id= ? AND value_range is not null",params[:question], params[:option])
    @media = 0

    @answers.each do |answer|
      @media = @media + answer.value_range
    end
    @media = @media / @answers.count if @media > 0 &&  @answers.count > 0
    #render :other_answers
  end

  def number_answers
    @question = Legislation::Question.find(params[:question])
    @answers = Legislation::Answer.where("legislation_question_id = ? AND legislation_question_option_id= ? AND value_number is not null",params[:question], params[:option])
   
    #render :other_answers
  end

  def create
    @question.author = current_user
    @question.multiple_answers = 1 if question_params[:multiple_answers].blank?
    if @question.save
      notice = t("admin.legislation.questions.create.notice", link: question_path)
      redirect_to admin_legislation_process_questions_path, notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.create.error")
      render :new
    end
  end

  def update
    if @question.update(question_params)
      notice = t("admin.legislation.questions.update.notice", link: question_path)
      redirect_to edit_admin_legislation_process_question_path(@process, @question), notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.update.error")
      render :edit
    end
  end

  def destroy
    begin
      @question.hidden_at = Time.zone.now
    if @question.save!
      redirect_to admin_legislation_process_questions_path, notice: t("admin.legislation.questions.destroy.notice")
    end
    rescue
      redirect_to admin_legislation_process_questions_path, alert: t("admin.legislation.questions.destroy.error")
    end
  end

  # def destroy_question_option
  #   puts "======================================"
  #   puts params
  #   puts "======================================"
  #   xxxx
  #   redirect_to edit_admin_legislation_process_question_path(@process, question)
  # end

  private

    def question_path
      legislation_process_question_path(@process, @question).html_safe
    end

    def question_params
      params.require(:legislation_question).permit(
        translation_params(::Legislation::Question), :is_range,
        :multiple_answers, question_options_attributes: [:id, :_destroy, :is_range,
                                      translation_params(::Legislation::QuestionOption)]
      )
    end

    def resource
      @question || ::Legislation::Question.find(params[:id])
    end
end
