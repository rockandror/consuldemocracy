module Comments
  class VotesController < ApplicationController
    before_action :authenticate_user!, only: [:create, :hide]
    load_and_authorize_resource :comment

    def create
      @comment.vote_by(voter: current_user, vote: params[:value])

      respond_to do |format|
        format.js { render :show }
      end
    end

    def destroy
      if params[:value] == "yes"
        @comment.unliked_by(current_user)
      else
        @comment.undisliked_by(current_user)
      end

      respond_to do |format|
        format.js { render :show }
      end
    end
  end
end
