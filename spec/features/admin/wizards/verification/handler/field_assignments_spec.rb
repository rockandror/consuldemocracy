require "rails_helper"

describe "Admin wizards verification handler fields assignments" do
  let!(:fake_handler) do
    Class.new(Verification::Handler) do
      register_as :fake_handler
    end
  end
  let!(:field) { create(:verification_field, label: "Email", name: "email", position: 1) }

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  describe "Index" do
    scenario "Should show defined verification fields" do
      create(:verification_handler_field_assignment, verification_field: field, handler: fake_handler.id)
      visit admin_wizards_verification_handler_field_assignments_path("fake_handler")

      expect(page).to have_content "email"
    end
  end

  describe "Create" do
    scenario "Should show successful notice after creating a new field" do
      visit new_admin_wizards_verification_handler_field_assignment_path("fake_handler")

      select "email", from: "Verification field"
      click_button "Save"

      expect(page).to have_content "Field assignment created successfully!"
    end

    scenario "Should show validation errors alert and message after submitting
              an invalid field" do
      create(:verification_handler_field_assignment, verification_field: field, handler: fake_handler.id)
      visit new_admin_wizards_verification_handler_field_assignment_path("fake_handler")

      select "email", from: "Verification field"
      click_button "Save"

      message = "1 error prevented this Verification/Handler/Field Assignment from being saved."
      expect(page).to have_content message
      expect(page).to have_content "has already been taken"
    end
  end

  describe "Update" do
    scenario "Should show successful notice after creating a new field" do
      field_assignment = create(:verification_handler_field_assignment, verification_field: field,
                                                                        handler: fake_handler.id)
      create(:verification_field, label: "Phone", name: "phone", position: 2)
      visit edit_admin_wizards_verification_handler_field_assignment_path("fake_handler", field_assignment)

      select "phone", from: "Verification field"
      click_button "Save"

      expect(page).to have_content "Field assignment updated successfully!"
    end
  end

  describe "Destroy" do
    scenario "Should show successful notice after delete a field" do
      visit admin_wizards_verification_fields_path

      click_link "Delete"

      expect(page).to have_content "Verification field deleted successfully"
    end
  end
end
