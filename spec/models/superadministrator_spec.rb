require "rails_helper"

describe Superadministrator do

  let(:superadministrator) { build(:superadministrator) }

  describe "validations" do
    it "should be valid" do
      expect(superadministrator).to be_valid
    end
  end

end
