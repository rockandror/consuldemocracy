class Admin::Poll::Questions::Answers::VideosController < Admin::Poll::BaseController
  load_resource :answer, class: "::Poll::Question::Answer"
  load_resource :video, class: "::Poll::Question::Answer::Video"

  before_action :authorize_create_video, only: :create
  before_action :authorize_edit_video, only: [:edit, :update]
  before_action :authorize_destroy_video, only: :destroy

  def index
  end

  def new
    @video = ::Poll::Question::Answer::Video.new
  end

  def create
    @video = ::Poll::Question::Answer::Video.new(video_params)

    if @video.save
      redirect_to admin_answer_videos_path(@answer),
               notice: t("flash.actions.create.poll_question_answer_video")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @video.update(video_params)
      redirect_to admin_answer_videos_path(@video.answer_id),
               notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    notice = if @video.destroy
               t("flash.actions.destroy.poll_question_answer_video")
             else
               t("flash.actions.destroy.error")
             end
    redirect_back(fallback_location: (request.referer || root_path), notice: notice)
  end

  private

    def video_params
      params.require(:poll_question_answer_video).permit(allowed_params)
    end

    def allowed_params
      [:title, :url, :answer_id]
    end

    def authorize_create_video
      if cannot? :create, @video
        redirect_to admin_answer_videos_path(@video.answer), alert: t("unauthorized.create.poll/question/answer/video")
      end
    end

    def authorize_edit_video
      if cannot? :edit, @video
        redirect_to admin_answer_videos_path(@video.answer), alert: t("unauthorized.update.poll/question/answer/video")
      end
    end

    def authorize_destroy_video
      if cannot? :destroy, @video
        redirect_to admin_answer_videos_path(@video.answer), alert: t("unauthorized.destroy.poll/question/answer/video")
      end
    end
end
