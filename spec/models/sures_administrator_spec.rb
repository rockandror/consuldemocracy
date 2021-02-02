require "rails_helper"

describe SuresAdministrator do

  let(:sures_administrator) { build(:sures_administrator) }

  describe "validations" do
    it "should be valid" do
      expect(sures_administrator).to be_valid
    end
  end

end
