require "rails_helper"

describe "Verification process" do
  let!(:name_field)        { create(:verification_field, name: "name", label: "Name", position: 1) }
  let!(:email_field)       { create(:verification_field, name: "email", label: "Email", position: 2) }
  let!(:phone_field)       { create(:verification_field, name: "phone", label: "Phone", position: 3) }
  let!(:postal_code_field) do
    create(:verification_field, name: "postal_code", label: "Postal code", position: 4)
  end
  let!(:document_type_field) do
    create(:verification_field, name: "document_type", label: "Document type", position: 5)
  end
  let!(:document_number_field) do
    create(:verification_field, name: "document_number", label: "Document number", position: 6)
  end
  let(:user)               { create(:user) }

  before do
    Setting["feature.custom_verification_process"] = true
    Setting["custom_verification_process.remote_census"] = true
    Setting["custom_verification_process.residents"] = true
    Setting["custom_verification_process.sms"] = true
    login_as(user)
  end

  describe "New" do
    scenario "Redirect already verified users to accoung page showing a notice" do
      create(:verification_process, user: user)
      user.reload
      visit new_verification_process_path

      expect(page).to have_content "My account"
      expect(page).to have_content "Your account is already verified"
    end

    scenario "Shows all defined verification fields" do
      create(:verification_field, name: "date_of_birth", label: "Date of birth", position: 7, kind: :date)
      create(:verification_field, name: "field_with_visible_false", label: "Sample field", position: 8,
                                  visible: false)

      visit new_verification_process_path

      expect(page).to have_field "verification_process_name"
      expect(page).to have_field "verification_process_email"
      expect(page).to have_field "verification_process_phone"
      expect(page).to have_field "verification_process_postal_code"
      expect(page).to have_field "verification_process_document_number"
      expect(page).to have_field "verification_process_document_type"
      expect(page).to have_select "verification_process_date_of_birth_1i"
      expect(page).to have_select "verification_process_date_of_birth_2i"
      expect(page).to have_select "verification_process_date_of_birth_3i"
      expect(page).not_to have_field "verification_process_field_with_visible_false"
    end

    scenario "Shows confirmation fields next to parent fields" do
      name_field.update!(confirmation_validation: true)
      visit new_verification_process_path

      expect("Name").to appear_before("Name confirmation")
      expect("Name confirmation").to appear_before("Email")
    end

    scenario "when fields hints are defined it should be shown" do
      name_field.update!(hint: "Name hint")
      visit new_verification_process_path

      expect(page).to have_content("Name hint")
    end

    context "with other kinds field" do

      scenario "Show defined checkbox fields" do
        create(:verification_field, name: "checkbox_field", label: "TOS", position: 7, kind: "checkbox")

        visit new_verification_process_path

        expect(page).to have_field "TOS"
      end

      scenario "Show defined selector fields" do
        selector_field = create(:verification_field, name: "selector_field", label: "Sample selector field",
                                                     position: 7, kind: "selector")
        create(:verification_field_option, label: "Option 1", value: "1", verification_field: selector_field)

        visit new_verification_process_path

        expect(page).to have_select "verification_process_selector_field"
        expect(page).to have_content "Sample selector field"
      end
    end
  end

  describe "Create" do
    scenario "Shows fields presence validation errors" do
      name_field.update!(required: true)
      visit new_verification_process_path

      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "can't be blank"
    end

    scenario "Shows fields confirmation validation errors" do
      phone_field.update!(confirmation_validation: true)
      visit new_verification_process_path

      fill_in "Phone", with: "666555444"
      fill_in "Phone confirmation", with: "666555443"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "doesn't match"
    end

    scenario "Shows fields format validation errors" do
      phone_field.update!(format: '\A[\d \+]+\z')
      visit new_verification_process_path

      fill_in "Phone", with: "234 234 234A"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "invalid"
    end

    scenario "Shows special validations from handlers" do
      create(:user, confirmed_phone: "234234234")
      phone_field.update!(format: '\A[\d \+]+\z')
      create(:verification_field_assignment, verification_field: phone_field, handler: "sms")
      visit new_verification_process_path

      fill_in "Name", with: "My Fabolous Name"
      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "234234234"
      click_button "Verify my account"

      expect(page).to have_content "1 error prevented this Verification/Process from being saved"
      expect(page).to have_content "has already been taken"
    end

    scenario "When one step verification process without active handlers has not errors
              user should be marked as verified user and redirect to profile page with a notice" do
      visit new_verification_process_path

      fill_in "Name", with: "My Fabolous Name"
      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "234234234"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with required checkbox without active handlers
              has not errors user should be display related link and marked as verified user and
              redirect to profile page with a notice" do

      custom_page = create(:site_customization_page, slug: "new_page_tos_slug")
      create(:verification_field, name: "tos", label: "Terms of service", position: 7, required: true,
                                  checkbox_link: "new_page_tos_slug", kind: "checkbox")
      visit new_verification_process_path

      check "verification_process_tos"

      expect(page).to have_link("link", href: custom_page.url)

      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with required selector without active handlers
              has not errors user should be display related link and marked as verified user and
              redirect to profile page with a notice" do

      selector_field = create(:verification_field, name: "selector_field", label: "Sample selector field",
                                                   position: 7, kind: "selector", required: true)
      create(:verification_field_option, label: "Option 1", value: "1", verification_field: selector_field)

      visit new_verification_process_path
      select "Option 1", from: :verification_process_selector_field
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with residents active handler has not errors
              user should be marked as verified user and redirect to profile page with a notice" do
      create(:verification_resident, data: { name: "Fabulous Name",
                                             email: "email@example.com",
                                             phone: "111222333",
                                             postal_code: "00700" })
      create(:verification_field_assignment, verification_field: name_field, handler: "residents")
      create(:verification_field_assignment, verification_field: email_field, handler: "residents")
      create(:verification_field_assignment, verification_field: phone_field, handler: "residents")
      create(:verification_field_assignment, verification_field: postal_code_field,
        handler: "residents")
      visit new_verification_process_path

      fill_in "Name", with: "Fabulous Name"
      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "111222333"
      fill_in "Postal code", with: "00700"
      click_button "Verify my account"

      expect(page).to have_content "Your account was successfully verified!"
    end

    scenario "When one step verification process with remote_census active handler has not errors
              user should be marked as verified user and redirect to profile page with a notice" do
      valid_response_path = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      Setting["remote_census.response.valid"] = valid_response_path
      postal_code_response_path = "get_habita_datos_response.get_habita_datos_return.datos_vivienda." \
                                  "item.codigo_postal"
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

    scenario "When one step verification process with residents and sms as active handlers has not errors
              user should be marked as verified user and redirect to profile page with a notice" do
      create(:verification_resident, data: { name: "Fabulous Name",
                                             email: "email@example.com",
                                             phone: "111222333",
                                             postal_code: "00700" })
      create(:verification_field_assignment, verification_field: name_field, handler: "residents")
      create(:verification_field_assignment, verification_field: email_field, handler: "residents")
      create(:verification_field_assignment, verification_field: phone_field, handler: "residents")
      create(:verification_field_assignment, verification_field: postal_code_field,
        handler: "residents")
      create(:verification_field_assignment, verification_field: phone_field, handler: "sms")
      visit new_verification_process_path

      fill_in "Name", with: "Fabulous Name"
      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "111222333"
      fill_in "Postal code", with: "00700"
      click_button "Verify my account"

      expect(page).not_to have_content "Your account was successfully verified!"
      expect(page).to have_content "Enter confirmation codes to verify your account"
      expect(page).to have_field "SMS confirmation code"
    end

    scenario "When two step verification process has not errors user
              should be redirected to confirmation codes page" do
      create(:verification_field_assignment, verification_field: phone_field, handler: "sms")
      visit new_verification_process_path

      fill_in "Name", with: "My Fabolous Name"
      fill_in "Email", with: "email@example.com"
      fill_in "Phone", with: "234234234"
      click_button "Verify my account"

      expect(page).not_to have_content "Your account was successfully verified!"
      expect(page).to have_content "Enter confirmation codes to verify your account"
      expect(page).to have_field "SMS confirmation code"
    end
  end
end
