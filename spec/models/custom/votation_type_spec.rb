require "rails_helper"

describe VotationType do
  context "Open votation type" do
    let(:votation_type) { build(:votation_type_open) }

    it "is valid" do
      expect(votation_type).to be_valid
    end

    it "is not valid without questionable" do
      votation_type.questionable = nil

      expect(votation_type).not_to be_valid
    end

    it "is not valid when questionable_type is not allowed" do
      votation_type.questionable_type = Poll::Answer

      expect(votation_type).not_to be_valid
      expect(votation_type.errors[:questionable_type]).to include "is not included in the list"
    end

    it "is valid when max_votes is undefined for open votation_type" do
      votation_type.max_votes = nil
      votation_type.vote_type = "open"

      expect(votation_type).to be_valid
    end
  end
end
