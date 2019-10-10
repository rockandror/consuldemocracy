require "rails_helper"

describe "Wizard Verification Handlers" do

  before do
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  context "Index" do
    scenario "Display default custom verification process settings" do
      visit admin_wizards_verification_handlers_path

      expect(page).to have_content "Verify a user against SOAP Remote Census"
      expect(page).to have_content "Configure the remote census to be used during user verification process."

      expect(page).to have_content "Verify a user against the Local Census"
      expect(page).to have_content "Configure the local census to be used in the verification of a user in the application."

      expect(page).to have_content "Verify a user's phone"
      expect(page).to have_content "Configure user's phone verification to use it during the verification process. "
    end

    scenario "Allow enable a new custom verification process setting" do
      setting = Setting.create(key: "custom_verification_process.sample_key")

      visit admin_wizards_verification_handlers_path
      find("#edit_setting_#{setting.id} .button").click

      expect(page).to have_content "Value updated"
    end
  end

end
