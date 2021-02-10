require "rails_helper"

describe Sures::Actuation do

  let(:sures_actuation) { build(:sures_actuation) }

  describe "validations" do
    it "should be valid" do
      expect(sures_actuation).to be_valid
    end
  end

end
