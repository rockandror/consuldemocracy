require_dependency Rails.root.join("app", "controllers", "comments_controller").to_s

class CommentsController
  skip_authorize_resource only: :create
  before_action :authorize_comment_creation!, only: :create

  private

    def authorize_comment_creation!
      if commenting_as_moderator?
        authorize! :comment_as_moderator, @commentable
      elsif commenting_as_administrator?
        authorize! :comment_as_administrator, @commentable
      else
        authorize! :create, Comment.new(commentable: @commentable)
      end
    end

    def commenting_as_administrator?
      ["1", true].include?(comment_params[:as_administrator])
    end

    def commenting_as_moderator?
      ["1", true].include?(comment_params[:as_moderator])
    end
end
