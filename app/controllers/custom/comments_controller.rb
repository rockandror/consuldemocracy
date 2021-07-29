require_dependency Rails.root.join("app", "controllers", "comments_controller").to_s

class CommentsController
  load_and_authorize_resource except: :create
  load_resource only: :create

  def create
    authorize_comment_creation!
    if @comment.save
      CommentNotifier.new(comment: @comment).process
      add_notification @comment
      EvaluationCommentNotifier.new(comment: @comment).process if send_evaluation_notification?
    else
      render :new
    end
  end

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

    def administrator_comment?
      commenting_as_administrator? && can?(:comment_as_administrator, @commentable)
    end

    def moderator_comment?
      commenting_as_moderator? && can?(:comment_as_moderator, @commentable)
    end

    def commenting_as_administrator?
      ["1", true].include?(comment_params[:as_administrator])
    end

    def commenting_as_moderator?
      ["1", true].include?(comment_params[:as_moderator])
    end
end
