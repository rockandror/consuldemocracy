require "rails_helper"

describe Visit do

  let(:visit) { build(:visit) }

  describe "validations" do
    it "should be valid" do
      expect(visit).to be_valid
    end
  end

end
