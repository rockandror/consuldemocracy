module Debates
  class VotesController < ApplicationController
    load_and_authorize_resource :debate
    #load_and_authorize_resource through: :debate, through_association: :votes_for, only: :destroy

    def create
      authorize! :create, Vote.new(voter: current_user, votable: @debate)
      @debate.register_vote(current_user, params[:value])

      respond_to do |format|
        format.js { render :show }
      end
    end

    def destroy
      authorize! :destroy, Vote.new(voter: current_user, votable: @debate)
      if params[:value] == "yes"
        @debate.unliked_by(current_user)
      else
        @debate.undisliked_by(current_user)
      end

      respond_to do |format|
        format.js { render :show }
      end
    end
  end
end
