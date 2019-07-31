require "rails_helper"

RSpec.describe SettingsHelper, type: :helper do

  describe "#setting" do

    it "returns a hash with all settings values" do
      Setting["key1"] = "value1"
      Setting["key2"] = "value2"

      expect(setting["key1"]).to eq("value1")
      expect(setting["key2"]).to eq("value2")
      expect(setting["key3"]).to eq(nil)
    end
  end

  describe "#feature?" do
    it "returns presence of feature flag setting value" do

      Setting["feature.f1"] = "active"
      Setting["feature.f2"] = ""
      Setting["feature.f3"] = nil

      expect(feature?("f1")).to eq("active")
      expect(feature?("f2")).to eq(nil)
      expect(feature?("f3")).to eq(nil)
      expect(feature?("f4")).to eq(nil)
    end
  end

  describe "#social_feature?" do
    it "returns true when social setting is a feature flag" do
      social_setting_flag = Setting.create(key: "social.sample_social.login")
      social_setting_input = Setting.create(key: "social.sample_social.input")
      social_setting_one_level = Setting.create(key: "social.one_level")
      another_setting = Setting.create(key: "another_setting.sample_key")

      expect(social_feature?(social_setting_flag)).to eq true
      expect(social_feature?(social_setting_input)).to eq false
      expect(social_feature?(social_setting_one_level)).to eq false
      expect(social_feature?(another_setting)).to eq false
    end
  end

  describe "#regional_feature?" do
    it "returns true when regional setting is a feature flag" do
      regional_setting_flag = Setting.create(key: "regional.available_locale.login")
      regional_setting_input = Setting.create(key: "regional.sample_regional.input")
      regional_setting_one_level = Setting.create(key: "regional.one_level")
      another_setting = Setting.create(key: "another_setting.sample_key")

      expect(regional_feature?(regional_setting_flag)).to eq true
      expect(regional_feature?(regional_setting_input)).to eq false
      expect(regional_feature?(regional_setting_one_level)).to eq false
      expect(regional_feature?(another_setting)).to eq false
    end
  end

end
