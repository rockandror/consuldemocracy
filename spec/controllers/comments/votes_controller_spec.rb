require "rails_helper"

describe Comments::VotesController do
  let(:comment) { create(:comment) }

  describe "POST create" do
    describe "Vote" do
      it "allows vote" do
        sign_in create(:user)

        expect do
          post :create, xhr: true, params: { comment_id: comment.id, value: "yes" }
        end.to change { comment.reload.votes_for.size }.by(1)
      end
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    let!(:vote) { create(:vote, votable: comment, voter: user) }

    it "allows undo vote" do
      sign_in user

      expect do
        delete :destroy, xhr: true, params: { comment_id: comment.id, value: "yes", id: vote }
      end.to change { comment.reload.votes_for.size }.by(-1)
    end
  end
end
