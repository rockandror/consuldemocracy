shared_examples "votable" do
  let(:votable) { create(model_name(described_class)) }
  let(:user) { create(:user, verified_at: Time.current) }

  describe "#undo_vote" do
    it "apply unliked vote when user had voted 'yes'" do
      votable.register_vote(user, "yes")

      expect(user.voted_up_on?(votable)).to eq true
      expect(user.voted_down_on?(votable)).to eq false

      expect { votable.undo_vote(user, "yes") }.to change { votable.votes_for.size }.by(-1)

      expect(user.voted_up_on?(votable)).to eq false
      expect(user.voted_down_on?(votable)).to eq false
    end

    it "apply undisliked vote when user had voted 'no'" do
      votable.register_vote(user, "no")

      expect(user.voted_up_on?(votable)).to eq false
      expect(user.voted_down_on?(votable)).to eq true

      expect { votable.undo_vote(user, "no") }.to change { votable.votes_for.size }.by(-1)

      expect(user.voted_up_on?(votable)).to eq false
      expect(user.voted_down_on?(votable)).to eq false
    end
  end

  describe "#undo_vote?" do
    it "is true when the user votes the same value he has already voted" do
      votable.register_vote(user, "yes")

      expect(votable.undo_vote?(user, "yes")).to eq true
    end

    it "is false when the user change his vote" do
      votable.register_vote(user, "yes")

      expect(votable.undo_vote?(user, "no")).to eq false
    end

    it "is false when the user votes for the first time" do
      expect(votable.undo_vote?(user, "yes")).to eq false
    end
  end
end
