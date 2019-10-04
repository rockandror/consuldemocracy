require "rails_helper"

describe "Wizard Verifcation" do

  before do
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  context "Steps" do
    scenario "Initial step" do
      visit new_admin_wizards_verification_path

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "Welcome to the verification process assistant"
      expect(page).to have_content "In this assistant we will carry out step by step all necessary configuration to be able to personalize the Verification system of the application to the needs of each institution."
      expect(page).to have_content "If you have modified the verification system and want to use your code DO NOT continue running this wizard."
      expect(page).to have_link("Ok, Exit this wizard for now!", href: admin_root_path)
      expect(page).to have_content "For the changes made in this wizard to take effect, you must disabled 'skip verification' and enable 'Customizable user verification process'."
      expect(page).to have_css(".setting", count: 2)
      expect(page).to have_content "Customizable user verification process"
      expect(page).to have_content "Skip user verification"
      expect(page).to have_link("Start", href: admin_wizards_verification_fields_path)
    end

    scenario "Verification fields step" do
      visit admin_wizards_verification_fields_path

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "Verification fields"
      expect(page).to have_content "Pending..."
      expect(page).to have_content "Create field"
      expect(page).to have_link("Back", href: new_admin_wizards_verification_path)
      expect(page).to have_link("Next", href: admin_wizards_verification_handlers_path)
    end

    scenario "User verification methods step" do
      Setting["custom_verification_process.census_soap"] = true

      visit admin_wizards_verification_handlers_path

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "User verification methods"
      expect(page).to have_content 'Define custom fields to ask user during verification process. Pending...'
      expect(page).to have_link("Back", href: admin_wizards_verification_fields_path)
      expect(page).to have_link("Next", href: admin_wizards_verification_handler_field_assignments_path(:remote_census))
      expect(page).to have_css(".setting", count: 3)
      expect(page).to have_content "Verify a user against SOAP Remote Census"
      expect(page).to have_content "Verify a user against the Local Census"
      expect(page).to have_content "Verify a user's phone"
    end

    scenario "Configure remote census verification process step" do
      Setting["custom_verification_process.census_soap"] = true
      Setting["custom_verification_process.census_local"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:remote_census)

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "Configure remote census verification process"
      expect(page).to have_content "Add the verification fields you want to send to remote census."
      expect(page).to have_link("Back", href: admin_wizards_verification_handlers_path)
      expect(page).to have_link("Next", href: admin_wizards_verification_handler_field_assignments_path(:resident))
      expect(page).to have_link("Associate field to this verification process", href: new_admin_wizards_verification_handler_field_assignment_path(:remote_census))
    end

    scenario "Configure local census verification process step" do
      Setting["custom_verification_process.census_soap"] = true
      Setting["custom_verification_process.census_local"] = true
      Setting["custom_verification_process.sms"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:resident)

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "Configure local census verification process"
      expect(page).to have_content "Add the verification fields you want to check against to local census database."
      expect(page).to have_link("Back", href: admin_wizards_verification_handler_field_assignments_path(:remote_census))
      expect(page).to have_link("Next", href: admin_wizards_verification_handler_field_assignments_path(:sms))
      expect(page).to have_link("Associate field to this verification process", href: new_admin_wizards_verification_handler_field_assignment_path(:resident))
    end

    scenario "Configure phone verification process step" do
      Setting["custom_verification_process.census_local"] = true
      Setting["custom_verification_process.sms"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:sms)

      expect(page).to have_content "Verification Wizard"
      expect(page).to have_content "Configure phone verification process"
      expect(page).to have_content "Add the phone field to get phone from user and to verify it by SMS."
      expect(page).to have_link("Back", href: admin_wizards_verification_handler_field_assignments_path(:resident))
      expect(page).to have_link("Next", href: "")
      expect(page).to have_link("Associate field to this verification process", href: new_admin_wizards_verification_handler_field_assignment_path(:sms))
    end

  end

end
