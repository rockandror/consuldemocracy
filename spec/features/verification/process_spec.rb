require "rails_helper"

describe "Verification process" do
  let(:user)               { create(:user) }

  before do
    Setting["feature.custom_verification_process"] = true
    login_as(user)
  end

  describe "New" do
    before { Setting["feature.custom_verification_process"] = true }

    scenario "Redirect already verified users to account page showing a notice" do
      create(:verification_process, user: user)
      user.reload # Why we need this line?

      visit new_verification_process_path

      expect(page).to have_content "My account"
      expect(page).to have_content "Your account is already verified"
    end

    scenario "Render visible verification fields" do
      create(:verification_field, name: "name")
      create(:verification_field, name: "hidden", visible: false)

      visit new_verification_process_path

      expect(page).to have_field "verification_process_name"
      expect(page).not_to have_field "verification_process_hidden"
    end

    scenario "Render confirmation fields next to parent fields" do
      create(:verification_field, name: "phone", label: "Phone", confirmation_validation: true, position: 1)
      create(:verification_field, name: "email", label: "Email", position: 2)

      visit new_verification_process_path

      expect("Phone").to appear_before("Phone confirmation")
      expect("Phone confirmation").to appear_before("Email")
    end

    scenario "Render fields hints when defined" do
      create(:verification_field, name: "phone", hint: "Enter a valid spanish mobile phone number.")

      visit new_verification_process_path

      expect(page).to have_content("Enter a valid spanish mobile phone number.")
    end

    scenario "Render checkbox fields" do
      create(:verification_field, name: "tos", label: "TOS", kind: "checkbox")

      visit new_verification_process_path

      expect(page).to have_field "TOS", type: "checkbox"
    end

    scenario "Render checkbox field with link" do
      page = create(:site_customization_page, slug: "slug")
      create(:verification_field, name: "tos", checkbox_link: "slug", kind: "checkbox")

      visit new_verification_process_path

      expect(page).to have_link("link", href: page.url)
    end

    scenario "Render select fields with defined options" do
      field = create(:verification_field, name: "document", kind: "selector")
      create(:verification_field_option, label: "Option 1", verification_field: field)

      visit new_verification_process_path

      expect(page).to have_select "verification_process_document"
      expect(page).to have_content "Option 1"
    end

    scenario "Render date fields as native date select" do
      create(:verification_field, name: "date_of_birth", kind: "date")

      visit new_verification_process_path

      expect(page).to have_select "verification_process_date_of_birth_1i"
      expect(page).to have_select "verification_process_date_of_birth_2i"
      expect(page).to have_select "verification_process_date_of_birth_3i"
    end
  end

  describe "Create" do
    scenario "Shows fields presence validation errors" do
      create(:verification_field, required: true)
      visit new_verification_process_path

      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "can't be blank"
    end

    scenario "Shows fields confirmation validation errors" do
      create(:verification_field, label: "Phone", confirmation_validation: true)
      visit new_verification_process_path

      fill_in "Phone", with: "666555444"
      fill_in "Phone confirmation", with: "666555443"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "doesn't match"
    end

    scenario "Shows fields format validation errors" do
      create(:verification_field, label: "Phone", format: '\A[\d \+]+\z')
      visit new_verification_process_path

      fill_in "Phone", with: "234 234 234A"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "invalid"
    end

    scenario "Shows validations defined at handlers" do
      Setting["custom_verification_process.sms"] = true
      create(:user, confirmed_phone: "234234234")
      field = create(:verification_field, label: "Phone", name: :phone)
      create(:verification_field_assignment, verification_field: field, handler: :sms)
      visit new_verification_process_path

      fill_in "Phone", with: "234234234"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "has already been taken"
    end

    scenario "When one step verification process has not errors user should be verified successfully" do
      create(:verification_field, label: "Name")
      visit new_verification_process_path

      fill_in "Name", with: "My Fabolous Name"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with a required checkbox field has not errors " \
             "user should be verified successfully" do
      create(:verification_field, name: "tos", required: true, kind: "checkbox")

      visit new_verification_process_path
      check "verification_process_tos"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with required selector has not errors user should be "\
             "verified successfully" do

      selector_field = create(:verification_field, name: "selector_field", label: "Sample selector field",
                                                   position: 7, kind: "selector", required: true)
      create(:verification_field_option, label: "Option 1", value: "1", verification_field: selector_field)

      visit new_verification_process_path
      select "Option 1", from: :verification_process_selector_field
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with residents handler enabled has not errors " \
             "user should be verified successfully" do
      Setting["custom_verification_process.residents"] = true
      resident_data = { email: "email@example.com", phone: "111222333", postal_code: "00700" }
      create(:verification_resident, data: resident_data)
      email_field = create(:verification_field, name: :email, label: "Email")
      phone_field = create(:verification_field, name: :phone, label: "Phone")
      postal_code_field = create(:verification_field, name: :postal_code, label: "Postal code")
      create(:verification_field_assignment, verification_field: email_field, handler: :residents)
      create(:verification_field_assignment, verification_field: phone_field, handler: :residents)
      create(:verification_field_assignment, verification_field: postal_code_field, handler: :residents)
      visit new_verification_process_path

      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "111222333"
      fill_in "Postal code", with: "00700"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with remote_census enabled has not errors " \
             "user should be verified successfully" do
      Setting["custom_verification_process.remote_census"] = true
      valid_response_path = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      Setting["remote_census.response.valid"] = valid_response_path
      postal_code_response_path = "get_habita_datos_response.get_habita_datos_return.datos_vivienda." \
                                  "item.codigo_postal"
      document_number_field = create(:verification_field, name: :document_number, label: "Document number")
      document_type_field = create(:verification_field, name: :document_type, label: "Document type")
      postal_code_field = create(:verification_field, name: :postal_code, label: "Postal code")
      create(:verification_field_assignment, verification_field: document_type_field,
        handler: "remote_census", request_path: "request.document_type")
      create(:verification_field_assignment, verification_field: document_number_field,
        handler: "remote_census", request_path: "request.document_number")
      create(:verification_field_assignment, verification_field: postal_code_field,
        handler: "remote_census", response_path: postal_code_response_path)

      visit new_verification_process_path

      fill_in "Document type", with: "1"
      fill_in "Document number", with: "12345678Z"
      fill_in "Postal code", with: "28013"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When two step verification process has not errors user should be redirected to " \
             "confirmation codes page" do
      Setting["custom_verification_process.sms"] = true
      phone_field = create(:verification_field, name: :phone, label: "Phone")
      create(:verification_field_assignment, verification_field: phone_field, handler: "sms")
      visit new_verification_process_path

      fill_in "Phone", with: "234234234"
      click_button "Verify my account"

      expect(page).not_to have_content "Your account was successfully verified!"
      expect(page).to have_content "Enter confirmation codes to verify your account"
      expect(page).to have_field "SMS confirmation code"
    end
  end
end
