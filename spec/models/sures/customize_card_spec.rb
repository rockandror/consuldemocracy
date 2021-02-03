require "rails_helper"

describe Sures::CustomizeCard do

  let(:sures_customize_card) { build(:sures_customize_card) }

  describe "validations" do
    it "should be valid" do
      expect(sures_customize_card).to be_valid
    end
  end

end
