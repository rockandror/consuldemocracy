require "rails_helper"

describe "Verification confirmation" do
  let(:user)               { create(:user) }

  before do
    phone_field = create(:verification_field, name: :phone)
    create(:verification_field_assignment, verification_field: phone_field, handler: :sms)
    Setting["custom_verification_process.sms"] = true
    login_as(user)
  end

  describe "New" do
    scenario "Shows fields for all required confirmation codes" do
      visit new_verification_confirmation_path

      expect(page).to have_field "verification_confirmation_sms_confirmation_code"
    end

    scenario "Shows resend confirmation code info" do
      visit new_verification_confirmation_path

      expect(page).to have_content "Didn't get a text with your confirmation codes?"
      expect(page).to have_link("Click here to send it again", href: new_verification_process_path)
    end
  end

  describe "Create" do
    scenario "Shows presence error validations" do
      visit new_verification_confirmation_path

      click_button "Confirm"

      expect(page).to have_content "can't be blank"
    end

    scenario "Shows code confirmations error validations" do
      user.update!(sms_confirmation_code: "ABCD")
      visit new_verification_confirmation_path

      fill_in "SMS confirmation code", with: "ABCE"
      click_button "Confirm"

      expect(page).to have_content "Confirmation code does not match"
    end

    scenario "when confirmation codes are introduced successfully should redirect user to account page" do
      create(:verification_process, user: user, phone: "666555444")
      visit new_verification_confirmation_path

      fill_in "SMS confirmation code", with: user.reload.sms_confirmation_code
      click_button "Confirm"

      expect(page).to have_content "Accout verification process was done successfully!"
    end
  end
end
