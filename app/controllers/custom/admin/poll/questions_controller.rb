require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions_controller").to_s

class Admin::Poll::QuestionsController
  def create
    @question.author = @question.proposal&.author || current_user

    if @question.save
      if @question.vote_type == "open"
        redirect_to admin_poll_path(@question.poll)
      else
        redirect_to admin_question_path(@question)
      end
    else
      render :new
    end
  end

  def update
    if @question.update(question_params)
      if @question.vote_type == "open"
        redirect_to admin_poll_path(@question.poll), notice: t("flash.actions.save_changes.notice")
      else
        redirect_to admin_question_path(@question), notice: t("flash.actions.save_changes.notice")
      end
    else
      render :edit
    end
  end
end
