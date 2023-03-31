require "rails_helper"

describe "Admin settings", :admin do
  describe "Should redirect to same tab after update setting" do
    scenario "On #tab-security-options" do
      Setting.create!(key: "security_options.whatever")

      visit admin_settings_path
      click_link "Security options"

      within("tr", text: "Whatever") do
        click_button "No"

        expect(page).to have_button "Yes"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("h2", exact_text: "Security options")
    end
  end
end
