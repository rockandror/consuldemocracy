require "rails_helper"

describe Debates::VotesController do
  describe "POST create" do
    describe "Vote with too many anonymous votes" do
      it "allows vote if user is allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 100
        debate = create(:debate)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { debate_id: debate.id, value: "yes" }
        end.to change { debate.reload.votes_for.size }.by(1)
      end

      it "does not allow vote if user is not allowed" do
        Setting["max_ratio_anon_votes_on_debates"] = 0
        debate = create(:debate, cached_votes_total: 1000)
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { debate_id: debate.id, value: "yes" }
        end.not_to change { debate.reload.votes_for.size }
      end
    end
  end
end
