class Moderation::TopicsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{no_flags with_confirmed_hide_at}, only: [:index, :moderate, :comment]
  has_orders %w{newest}, only: :index

  before_action :load_resources, only: [:index, :moderate, :comment]

  load_and_authorize_resource

  def comments
    if !params[:topic_id].blank?
      if params[:filter] == "with_confirmed_hide_at"
        @comments = Comment.where(commentable_id: params[:topic_id], commentable_type: "Topic").where("confirmed_hide_at IS NOT NULL")
      else
        @comments = Comment.where(commentable_id: params[:topic_id], commentable_type: "Topic")
      end
      @valid_filters = ["no_flags", "with_confirmed_hide_at"]
      @valid_orders = ["newest"]
    else
      @comments = Comment.public_for_api
    end
    @comments = @comments.page(params[:page])
  end

  private

    def resource_model
      Topic
    end

    def author_id
      :author_id
    end
end
