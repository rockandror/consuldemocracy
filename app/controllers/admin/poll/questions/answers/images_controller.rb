class Admin::Poll::Questions::Answers::ImagesController < Admin::Poll::BaseController
  include ImageAttributes

  before_action :load_answer, except: :destroy
  before_action :load_image, only: :destroy
  # load_resource :answer, class: "::Poll::Question::Answer"
  # load_resource :image, class: "Image", through: :answer

  before_action :authorize_create_image, only: :create
  before_action :authorize_destroy_image, only: :destroy

  def index
  end

  def new
  end

  def create
    @answer.attributes = images_params

    if @answer.save
      redirect_to admin_answer_images_path(@answer),
               notice: t("flash.actions.create.poll_question_answer_image")
    else
      render :new
    end
  end

  def destroy
    @image.destroy!

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private

    def images_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      [:answer_id, images_attributes: image_attributes]
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:answer_id])
    end

    def load_image
      @image = ::Image.find(params[:id])
    end

    def authorize_create_image
      if cannot? :update, @answer
        redirect_to admin_answer_images_path(@answer), alert: t("unauthorized.create.poll/question/answer/image")
      end
    end

    def authorize_destroy_image
      if cannot? :update, @image.imageable
        redirect_to admin_answer_images_path(@image.imageable), alert: t("unauthorized.destroy.poll/question/answer/image")
      end
    end
end
