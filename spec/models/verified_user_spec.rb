require "rails_helper"

describe VerifiedUser do

  let(:verified_user) { build(:verified_user) }
  let(:user) { build(:user) }

  describe "validations" do
    it "should be valid" do
      expect(verified_user).to be_valid
    end

    it "should be valid phone" do
      expect(VerifiedUser.phone?(user)).not_to eq(nil)
    end
  end

end
