class CommunitiesController < ApplicationController
  TOPIC_ORDERS = %w{newest most_commented oldest}.freeze
  before_action :set_order, :set_community, :load_topics, :load_participants

  has_orders TOPIC_ORDERS

  skip_authorization_check

  def show
    @map_locations = @community.proposal.map_location if @community.proposal
    raise ActionController::RoutingError, "Not Found" unless communitable_exists?
    set_topic_votes(@topics)
    redirect_to root_path if Setting["feature.community"].blank?
  end

  def vote
    xxx
    @topic.register_vote(current_user, params[:value])
    set_topic_votes(@topics)
    log_event("topic", "vote", I18n.t("tracking.topics.name.#{params[:value]}"))
  end

  private

  def set_order
    @order = valid_order? ? params[:order] : "newest"
  end

  def set_community
    @community = Community.find(params[:id])
  end

  def load_topics
    @topics = @community.topics.send("sort_by_#{@order}").page(params[:page])
  end

  def load_participants
    @participants = @community.participants
  end

  def valid_order?
    params[:order].present? && TOPIC_ORDERS.include?(params[:order])
  end

  def communitable_exists?
    @community.proposal.present? || @community.investment.present?
  end
end
