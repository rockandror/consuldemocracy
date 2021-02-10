require "rails_helper"

describe Tagging do

  let(:tagging) { build(:tagging) }

  describe "validations" do
    it "should be valid" do
      expect(tagging).to be_valid
    end
  end
end
