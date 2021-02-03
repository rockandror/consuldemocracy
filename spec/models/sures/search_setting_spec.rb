require "rails_helper"

describe Sures::SearchSetting do

  let(:sures_search_setting) { build(:sures_search_setting) }

  describe "validations" do
    it "should be valid" do
      expect(sures_search_setting).to be_valid
    end
  end

end
