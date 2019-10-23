require "rails_helper"

describe "Verification confirmation" do
  let!(:phone_field)       { create(:verification_field, name: "phone", label: "Phone", position: 3) }
  let(:user)               { create(:user) }

  before do
    create(:verification_field_assignment, verification_field: phone_field, handler: "sms")
    Setting["feature.custom_verification_process"] = true
    Setting["custom_verification_process.remote_census"] = true
    Setting["custom_verification_process.residents"] = true
    Setting["custom_verification_process.sms"] = true
    login_as(user)
  end

  describe "New" do
    scenario "Shows fields for all required confirmation codes" do
      Class.new(Verification::Handler) do
        register_as :my_handler
        requires_confirmation true
      end
      Setting["custom_verification_process.my_handler"] = true
      create(:verification_field_assignment, verification_field: phone_field, handler: "my_handler")
      visit new_verification_confirmation_path

      expect(page).to have_field "verification_confirmation_sms_confirmation_code"
      expect(page).to have_field "verification_confirmation_my_handler_confirmation_code"
    end

    scenario "Shows resend confirmation code info" do
      Class.new(Verification::Handler) do
        register_as :my_handler
        requires_confirmation true
      end
      Setting["custom_verification_process.my_handler"] = true
      create(:verification_field_assignment, verification_field: phone_field, handler: "my_handler")
      visit new_verification_confirmation_path

      expect(page).to have_content "Didn't get a text with your confirmation codes?"
      expect(page).to have_link("Click here to send it again", href: new_verification_process_path)
    end
  end

  describe "Create" do
    scenario "Shows presence error validations" do
      Class.new(Verification::Handler) do
        register_as :my_handler
        requires_confirmation true
      end
      Setting["custom_verification_process.my_handler"] = true
      create(:verification_field_assignment, verification_field: phone_field, handler: "my_handler")
      visit new_verification_confirmation_path
      click_button "Confirm"

      expect(page).to have_content "can't be blank", count: 2
    end

    scenario "Shows code confirmations error validations" do
      Class.new(Verification::Handler) do
        register_as :my_handler
        requires_confirmation true

        def confirm(attributes)
          Verification::Handlers::Response.new false,
                                               "My handler confirmation code does not match",
                                               attributes,
                                               nil
        end
      end
      Setting["custom_verification_process.my_handler"] = true
      user.update(sms_confirmation_code: "ABCD")
      create(:verification_field_assignment, verification_field: phone_field, handler: "my_handler")
      visit new_verification_confirmation_path
      fill_in "SMS confirmation code", with: "ABCE"
      fill_in "My handler confirmation code", with: "QWER"
      click_button "Confirm"

      expect(page).to have_content "Confirmation code does not match"
      expect(page).to have_content "My handler confirmation code does not match"
    end

    scenario "when confirmation codes are introduced successfully should redirect user to account page" do
      Setting["custom_verification_process.my_handler"] = true
      create(:verification_process, user: user, phone: "666555444")
      visit new_verification_confirmation_path
      fill_in "SMS confirmation code", with: user.reload.sms_confirmation_code
      click_button "Confirm"

      expect(page).to have_content "Accout verification process was done successfully!"
    end
  end
end
