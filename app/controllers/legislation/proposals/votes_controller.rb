module Legislation
  module Proposals
    class VotesController < ApplicationController
      load_and_authorize_resource :process, class: "Legislation::Process"
      load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process
      load_and_authorize_resource through: :proposal, through_association: :votes_for, only: :destroy

      def create
        authorize! :create, Vote.new(voter: current_user, votable: @proposal)
        @proposal.vote_by(voter: current_user, vote: params[:value])

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
