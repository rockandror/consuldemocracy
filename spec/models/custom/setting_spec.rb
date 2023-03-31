require "rails_helper"

describe Setting do
  describe "#type" do
    it "returns the key prefix for 'security_options' settings" do
      security_options_setting = Setting.create!(key: "security_options.whatever")

      expect(security_options_setting.type).to eq "security_options"
    end
  end
end
