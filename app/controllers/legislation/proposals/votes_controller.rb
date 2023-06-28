module Legislation
  module Proposals
    class VotesController < ApplicationController
      load_and_authorize_resource :process, class: "Legislation::Process"
      load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

      def create
        @proposal.register_vote(current_user, params[:value])

        respond_to do |format|
          format.js { render :show }
        end
      end

      def destroy
        if params[:value] == "yes"
          @proposal.unliked_by(current_user)
        else
          @proposal.undisliked_by(current_user)
        end

        respond_to do |format|
          format.js { render :show }
        end
      end
    end
  end
end
