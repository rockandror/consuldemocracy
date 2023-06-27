require "rails_helper"

describe Legislation::Proposals::VotesController do
  let(:process) { create(:legislation_process) }
  let(:proposal) { create(:legislation_proposal, process: process) }

  describe "POST create" do
    describe "Vote" do
      it "allows vote if user is level_two_or_three_verified" do
        sign_in create(:user, :level_two)
        #{"value"=>"yes", "controller"=>"legislation/proposals/votes", "action"=>"create", "process_id"=>"8", "proposal_id"=>"4-dicta-minus-eum"}
        expect do
          post :create, xhr: true, params: { process_id: process.id, proposal_id: proposal.id, value: "yes" }
        end.to change { proposal.reload.votes_for.size }.by(1)
      end

      it "does not allow vote if user is not level_two_or_three_verified" do
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { process_id: process.id, proposal_id: proposal.id, value: "yes" }
        end.not_to change { proposal.reload.votes_for.size }
      end
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user, :level_two) }
    let!(:vote) { create(:vote, votable: proposal, voter: user) }

    it "allows undo vote" do
      sign_in user

      expect do
        delete :destroy, xhr: true, params: { process_id: process.id, proposal_id: proposal.id, value: "yes", id: vote }
      end.to change { proposal.reload.votes_for.size }.by(-1)
    end
  end
end
