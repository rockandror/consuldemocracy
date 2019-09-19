require "rails_helper"

describe "Fields" do

  let!(:fake_handler) do
    Class.new(Verification::Handler) do
      register_as :fake_handler
    end
  end
  let!(:field) { create(:verification_field, label: "Email", name: "email",
                                             handlers: "fake_handler", position: 1) }
  # Needed to use CommonActions::Translations module
  let(:translatable_class) { ::Verification::Field }
  let(:input_fields) { %w[label] }
  let(:textarea_fields) { [] }

  it_behaves_like "edit_translatable",
                  "verification_field",
                  "edit_admin_verification_field_path",
                  %w[label]

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  describe "Index" do
    scenario "Should show defined verification fields" do
      visit admin_verification_fields_path

      expect(page).to have_content "Email"
    end

    scenario "Should show verification fields in defined order" do
      create(:verification_field, label: "Phone", position: 2)
      visit admin_verification_fields_path

      expect("Email").to appear_before "Phone"
    end
  end

  describe "Create" do
    scenario "Should show successful notice after creating a new field" do
      visit new_admin_verification_field_path

      fill_in "Name", with: "Phone"
      fill_in_field "label", "en", with: "Phone"
      check "FakeHandler"
      fill_in "Position", with: 1
      check "Required?"
      click_button "Create field"

      expect(page).to have_content "Verification field created successfully"
    end

    scenario "Should show validation errors alert and message after submitting
              an invalid field" do
      visit new_admin_verification_field_path

      click_button "Create field"

      message = "4 errors prevented this field from being saved."
      expect(page).to have_content message
      expect(page).to have_content "Verification field couldn't be created"
    end
  end

  describe "Update" do
    scenario "Should show successful notice after creating a new field" do
      visit edit_admin_verification_field_path(field)

      check "Required?"
      click_button "Update field"

      expect(page).to have_content "Verification field updated successfully"
    end

    scenario "Should show validation errors alert after submitting an invalid
              field" do
      visit edit_admin_verification_field_path(field)

      fill_in "Name", with: ""
      click_button "Update field"

      expect(page).to have_content "Verification field couldn't be updated"
    end

    scenario "Should allow to deactivate all handlers for a field" do
      visit edit_admin_verification_field_path(field)
      expect(page).to have_checked_field("verification_field_handlers_fake_handler")

      uncheck "FakeHandler"
      click_button "Update field"

      expect(page).to have_content "Verification field updated successfully"
      visit edit_admin_verification_field_path(field)
      expect(page).to have_unchecked_field("verification_field_handlers_fake_handler")
    end
  end

  describe "Destroy" do
    scenario "Should show successful notice after delete a field" do
      visit admin_verification_fields_path

      click_link "Delete"

      expect(page).to have_content "Verification field deleted successfully"
    end
  end
end
