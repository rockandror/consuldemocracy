require "rails_helper"

describe "Admin wizards verification fields" do

  let!(:fake_handler) do
    Class.new(Verification::Handler) do
      register_as :fake_handler
    end
  end
  let!(:field) do
    create(:verification_field, label: "Email", name: "email", format: "sample_regex",
                                position: 1, kind: "text")
  end

  before do
    create(:verification_field_assignment, verification_field: field, handler: fake_handler.id)
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "Should show defined verification fields" do
      visit admin_wizards_verification_fields_path

      expect(page).to have_content "Email"
      expect(page).to have_content "sample_regex"
      expect(page).to have_content "Text field"
    end

    scenario "Should show verification fields in defined order" do
      create(:verification_field, label: "Phone", position: 2)
      visit admin_wizards_verification_fields_path

      expect("Email").to appear_before "Phone"
    end
  end

  context "New" do

    context "Should show related fields with kind field" do

      scenario "When kind field is :checkbox display checkbox_link field", :js do
        visit new_admin_wizards_verification_field_path

        select "Checkbox field", from: :verification_field_kind

        expect(page).to have_field "Link that will be shown next to a checkbox kind field"
      end

      scenario "When kind field is :selector display add_options link", :js do
        visit new_admin_wizards_verification_field_path

        select "Selector field", from: :verification_field_kind

        expect(page).to have_link "Add new option for select"
      end

      scenario "When kind field is :text not render other fields", :js do
        visit new_admin_wizards_verification_field_path

        select "Text field", from: :verification_field_kind

        expect(page).not_to have_field "Link that will be shown next to a checkbox kind field"
        expect(page).not_to have_link "Add new option for select"
      end

    end

    context "When kind field is :selector and click link for add new options" do

      scenario "Should show verification field options section with related fields and links", :js do
        visit new_admin_wizards_verification_field_path

        select "Selector field", from: :verification_field_kind
        click_link "Add new option for select"

        expect(page).to have_field "Label"
        expect(page).to have_field "Value"
        expect(page).to have_link "Remove option"
      end

    end
  end

  context "Create" do
    scenario "Should show successful notice after creating a new field" do
      visit new_admin_wizards_verification_field_path

      fill_in "Name", with: "Phone"
      fill_in "Label", with: "Phone"
      fill_in "Position", with: 1
      check "Required?"
      check "Require confirmation field?"
      check "Display field?"
      check "Is geozone field?"
      check "Is date of birth field?"
      fill_in "Format", with: "/\A[\d \+]+\z/"
      select "Text field", from: :verification_field_kind
      click_button "Create field"

      expect(page).to have_content "Verification field created successfully"
    end

    scenario "Should show validation errors alert and message after submitting
              an invalid field" do
      visit new_admin_wizards_verification_field_path

      click_button "Create field"

      message = "4 errors prevented this field from being saved."
      expect(page).to have_content message
      expect(page).to have_content "Verification field couldn't be created"
    end

    context "When kind field is :checkbox" do

      scenario "Should show successful notice after creating a new field with
                related checkbox fields", :js do
        visit new_admin_wizards_verification_field_path

        fill_in "Name", with: "Phone"
        fill_in "Label", with: "Phone"
        fill_in "Position", with: 1
        select "Checkbox field", from: :verification_field_kind
        fill_in "Link that will be shown next to a checkbox kind field", with: "sample_slug"
        click_button "Create field"

        expect(page).to have_content "Verification field created successfully"
      end

    end

    context "When kind field is :selector" do

      scenario "Should show successful notice after creating a new field with
                related selector fields", :js do
        visit new_admin_wizards_verification_field_path

        fill_in "Name", with: "Phone"
        fill_in "Label", with: "Phone"
        fill_in "Position", with: 1
        select "Selector field", from: :verification_field_kind
        click_link "Add new option for select"
        within "#field_verification_options_section" do
          fill_in "Label", with: "Sample label"
          fill_in "Value", with: "sample_value"
        end

        click_button "Create field"

        expect(page).to have_content "Verification field created successfully"
      end

      scenario "Should show validation errors alert and message after submitting
                an invalid field", :js do
        visit new_admin_wizards_verification_field_path

        select "Selector field", from: :verification_field_kind
        click_link "Add new option for select"
        click_button "Create field"

        message = "7 errors prevented this field from being saved."
        expect(page).to have_content message
        expect(page).to have_content "Verification field couldn't be created"
      end

    end

  end

  context "Update" do
    scenario "Should show successful notice after creating a new field" do
      visit edit_admin_wizards_verification_field_path(field)

      check "Required?"
      select "Checkbox field", from: :verification_field_kind
      click_button "Update field"

      expect(page).to have_content "Verification field updated successfully"
    end

    scenario "Should show validation errors alert after submitting an invalid
              field" do
      visit edit_admin_wizards_verification_field_path(field)

      fill_in "Name", with: ""
      click_button "Update field"

      expect(page).to have_content "Verification field couldn't be updated"
    end
  end

  context "Destroy" do
    scenario "Should show successful notice after delete a field" do
      visit admin_wizards_verification_fields_path

      click_link "Delete"

      expect(page).to have_content "Verification field deleted successfully"
    end
  end
end
