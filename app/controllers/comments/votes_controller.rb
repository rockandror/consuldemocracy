module Comments
  class VotesController < ApplicationController
    load_and_authorize_resource :comment
    before_action :authenticate_user!, only: [:create, :destroy]
    before_action :verify_comments_open!, only: [:create, :destroy]

    def create
      authorize! :create, Vote.new(voter: current_user, votable: @comment)
      @comment.vote_by(voter: current_user, vote: params[:value])

      respond_to do |format|
        format.js { render :show }
      end
    end

    def destroy
      authorize! :destroy, Vote.new(voter: current_user, votable: @comment)
      if params[:value] == "yes"
        @comment.unliked_by(current_user)
      else
        @comment.undisliked_by(current_user)
      end

      respond_to do |format|
        format.js { render :show }
      end
    end

    private

      def verify_comments_open!
        return if current_user.administrator? || current_user.moderator?

        if @comment.commentable.respond_to?(:comments_closed?) && @comment.commentable.comments_closed?
          redirect_to polymorphic_path(@comment.commentable), alert: t("comments.comments_closed")
        end
      end
  end
end
