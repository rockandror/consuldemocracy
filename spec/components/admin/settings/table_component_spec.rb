require "rails_helper"

describe Admin::Settings::TableComponent do
  describe "#key_header" do
    it "returns correct table header for the setting name colums" do
      settings = Setting.limit(2)

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).to have_content("Feature")

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "setting"

      expect(page).to have_content("Setting")

      setting_name = "remote_census_general_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("General Information")

      setting_name = "remote_census_request_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("Request Data")

      setting_name = "remote_census_response_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("Response Data")
    end
  end

  describe "#value_header" do
    it "returns correct table header for the setting interface column" do
      settings = Setting.limit(2)

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).to have_content("Enabled")

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "setting"

      expect(page).to have_content("Value")
    end
  end

  describe "#table_class" do
    it "returns a CSS class when all given settings have the type feature, otherwise returns nothing" do
      settings = [Setting.find_by(key: "feature.map"), Setting.find_by(key: "process.debates")]

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).to have_css(".featured-settings-table")

      settings = [Setting.find_by(key: "feature.map"), Setting.find_by(key: "process.debates"),
                  Setting.find_by(key: "mailer_from_name")]

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).not_to have_css(".featured-settings-table")
    end
  end

  describe "#column_class" do
    it "returns a CSS class when all given settings have mixed types, otherwise returns nothing" do
      settings = [Setting.find_by(key: "feature.map"), Setting.find_by(key: "process.debates")]

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).not_to have_css(".small-6")

      settings = [Setting.find_by(key: "feature.map"), Setting.find_by(key: "process.debates"),
                  Setting.find_by(key: "mailer_from_name")]

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "feature"

      expect(page).to have_css(".small-6")
    end
  end
end
