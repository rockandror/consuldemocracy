class Admin::TopicsController < Admin::BaseController

  has_filters %w{without_confirmed_hide all with_confirmed_hide}, only: :index

  before_action :load_topic, only: [:confirm_hide, :restore]

  def index
    @topics = Topic.only_hidden.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @topic.confirm_hide
    redirect_to admin_topics_path(params_strong)
  end

  def restore
    @topic.restore
    @topic.ignore_flag
    Activity.log(current_user, :restore, @topic)
    redirect_to admin_topics_path(params_strong)
  end

  private

    def params_strong
      params.permit(:filter)
    end

    def load_topic
      @topic = Topic.with_hidden.find(params[:id])
    end

end
