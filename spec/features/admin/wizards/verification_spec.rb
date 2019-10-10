require "rails_helper"

describe "Wizard verification" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  describe "Steps" do
    scenario "Initial step" do
      visit new_admin_wizards_verification_path

      expect(page).to have_content "Welcome to the verification process wizard"
      expect(page).to have_content "If you have modified the legacy Consul verification " \
                                   "system and want to keep using it do not continue running this wizard."
      expect(page).to have_link("Ok, get me out of here!", href: admin_root_path)
      expect(page).to have_content "For the changes made in this wizard to take effect, " \
                                   "you must disabled both 'skip verification' and 'Configure " \
                                   "connection to remote census (SOAP) - Legacy version' and enable " \
                                   "'Customizable user verification process'."
      expect(page).to have_css(".setting", count: 3)
      expect(page).to have_link("Start", href: admin_wizards_verification_fields_path)
    end

    scenario "User verification form. step" do
      visit admin_wizards_verification_fields_path

      expect(page).to have_content "User verification form."
      expect(page).to have_content "Create field"
      expect(page).to have_link("Back", href: new_admin_wizards_verification_path)
      expect(page).to have_link("Next", href: admin_wizards_verification_handlers_path)
    end

    scenario "User verification methods step" do
      Setting["custom_verification_process.remote_census"] = true

      visit admin_wizards_verification_handlers_path

      expect(page).to have_content "User verification methods"
      expect(page).to have_link("Back", href: admin_wizards_verification_fields_path)
      next_path = admin_wizards_verification_handler_field_assignments_path(:remote_census)
      expect(page).to have_link("Next", href: next_path)
      expect(page).to have_css(".setting", count: 3)
      expect(page).to have_content "Verify a user against SOAP Remote Census"
      expect(page).to have_content "Verify a user against the Local Census"
      expect(page).to have_content "Verify a user's phone"
    end

    scenario "Configure remote census verification process step" do
      Setting["custom_verification_process.remote_census"] = true
      Setting["custom_verification_process.residents"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:remote_census)

      expect(page).to have_content "Configure remote census verification process"
      expect(page).to have_link("Back", href: admin_wizards_verification_handlers_path)
      next_path = admin_wizards_verification_handler_field_assignments_path(:residents)
      expect(page).to have_link("Next", href: next_path)
      previous_path = new_admin_wizards_verification_handler_field_assignment_path(:remote_census)
      expect(page).to have_link("Associate field to this verification process", href: previous_path)
      expect(page).to have_css(".setting", count: 4)
      expect(page).to have_content "Endpoint"
      expect(page).to have_content "Request method name"
      expect(page).to have_content "Request Structure"
      expect(page).to have_content "Condition for detecting a valid response"
    end

    scenario "Configure local census verification process step" do
      Setting["custom_verification_process.remote_census"] = true
      Setting["custom_verification_process.residents"] = true
      Setting["custom_verification_process.sms"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:residents)

      expect(page).to have_content "Configure local census verification process"
      previous_path = admin_wizards_verification_handler_field_assignments_path(:remote_census)
      expect(page).to have_link("Back", href: previous_path)
      next_path = admin_wizards_verification_handler_field_assignments_path(:sms)
      expect(page).to have_link("Next", href: next_path)
      new_assignation_path = new_admin_wizards_verification_handler_field_assignment_path(:residents)
      expect(page).to have_link("Associate field to this verification process", href: new_assignation_path)
    end

    scenario "Configure phone verification process step" do
      Setting["custom_verification_process.residents"] = true
      Setting["custom_verification_process.sms"] = true

      visit admin_wizards_verification_handler_field_assignments_path(:sms)

      expect(page).to have_content "Configure phone verification process"
      previous_path = admin_wizards_verification_handler_field_assignments_path(:residents)
      expect(page).to have_link("Back", href: previous_path)
      next_path = admin_wizards_verification_finish_path
      expect(page).to have_link("Next", href: next_path)
      new_assignation_path = new_admin_wizards_verification_handler_field_assignment_path(:sms)
      expect(page).to have_link("Associate field to this verification process", href: new_assignation_path)
    end

    scenario "Finish verification process step" do
      Setting["custom_verification_process.sms"] = true

      visit admin_wizards_verification_finish_path

      expect(page).to have_content "Wizard successfully completed"
      expect(page).to have_link("Back", href: admin_wizards_verification_handler_field_assignments_path(:sms))
      expect(page).not_to have_link("Next")
      expect(page).to have_link("Finish Wizard", href: admin_root_path)
    end
  end
end
