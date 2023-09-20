require "rails_helper"

describe Legislation::Proposals::VotesController do
  let(:legislation_process) { create(:legislation_process) }
  let(:proposal) { create(:legislation_proposal, process: legislation_process) }

  describe "POST create" do
    let(:vote_params) do
      { process_id: legislation_process.id, legislation_proposal_id: proposal.id, value: "yes" }
    end

    describe "Vote" do
      it "allows vote if user is level_two_or_three_verified" do
        sign_in create(:user, :level_two)

        expect do
          post :create, xhr: true, params: vote_params
        end.to change { proposal.reload.votes_for.size }.by(1)
      end

      it "does not allow vote if user is not level_two_or_three_verified" do
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: vote_params
        end.not_to change { proposal.reload.votes_for.size }
      end
    end
  end
end
