module Debates
  class VotesController < ApplicationController
    load_and_authorize_resource :debate

    def create
      @debate.register_vote(current_user, params[:value])

      respond_to do |format|
        format.js { render :show }
      end
    end

    def destroy
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
