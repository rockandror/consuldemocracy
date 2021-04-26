require "rails_helper"

describe WebSection do

  let(:web_section) { build(:web_section) }

  describe "validations" do
    it "should be valid" do
      expect(web_section).to be_valid
    end
  end

end
