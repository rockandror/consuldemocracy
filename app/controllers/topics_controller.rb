class TopicsController < ApplicationController
  include CommentableActions

  before_action :load_community
  before_action :load_topic, only: [:show, :edit, :update, :destroy, :vote, :vote_featured]

  has_orders %w{most_voted newest oldest}, only: :show

  skip_authorization_check only: [:show, :vote, :vote_featured]
  load_and_authorize_resource except: [:show, :vote]

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params.merge(author: current_user, community_id: params[:community_id]))
    if @topic.save
      redirect_to community_path(@community), notice: I18n.t("flash.actions.create.topic")
    else
      render :new
    end
  end

  def show
    set_topic_votes(@topic)
    @commentable = @topic
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to community_path(@community), notice: t("flash.actions.update.topic")
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy
    redirect_to community_path(@community), notice: I18n.t("flash.actions.destroy.topic")
  end

  def vote
    @topic.register_vote(current_user, params[:value])
    set_topic_votes(@topic)
    log_event("topic", "vote", I18n.t("tracking.topics.name.#{params[:value]}"))
  end

  def vote_featured
    @topic.register_vote(current_user, "yes")
    set_featured_proposal_votes(@topic)
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :description)
  end

  def load_community
    @community = Community.find(params[:community_id])
  end

  def load_topic
    @topic = Topic.find(params[:id])
  end

  def load_rank
    @topic_rank ||= Topic.rank(@topic)
  end
end
