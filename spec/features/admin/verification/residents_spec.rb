require "rails_helper"

feature "Admin verification residents" do

  background do
    login_as(create(:administrator).user)
  end

  context "Index" do
    let!(:resident) { create(:verification_resident) }

    scenario "Should show empty message when no local census records exists" do
      Verification::Resident.delete_all
      visit admin_verification_residents_path

      expect(page).to have_content("There are no residents defined.")
    end

    scenario "Should show existing local census records" do
      visit admin_verification_residents_path

      expect(page).to have_content(resident.data.to_s)
    end

    scenario "Should show edit and destroy actions for each record" do
      visit admin_verification_residents_path

      within "#verification_resident_#{resident.id}" do
        expect(page).to have_link "Edit"
        expect(page).to have_link "Delete"
      end
    end

    scenario "Should show page entries info" do
      visit admin_verification_residents_path

      expect(page).to have_content("There is 1 resident")
    end

    scenario "Should show paginator" do
      create_list(:verification_resident, 25)
      visit admin_verification_residents_path

      within ".pagination" do
        expect(page).to have_link("2")
      end
    end
  end

  context "Create" do
    scenario "Should show validation errors" do
      visit new_admin_verification_resident_path

      fill_in :verification_resident_data, with: ""
      click_on "Save"

      expect(page).to have_content "1 error prevented this Verification/Resident from being saved."
      expect(page).to have_content "can't be blank", count: 1
    end

    scenario "Should show successful notice after create valid record" do
      visit new_admin_verification_resident_path

      fill_in :verification_resident_data, with: "{ email: \"user@email.com\"}"
      click_on "Save"

      expect(page).to have_content "New resident created successfully!"
      expect(page).to have_content "{ email: \"user@email.com\"}"
    end
  end

  context "Update" do
    let!(:resident) { create(:verification_resident) }

    scenario "Should show validation errors" do
      visit edit_admin_verification_resident_path(resident)

      fill_in :verification_resident_data, with: ""
      click_on "Save"

      expect(page).to have_content "1 error prevented this Verification/Resident from being saved."
      expect(page).to have_content "can't be blank", count: 1
    end

    scenario "Should show successful notice after valid update" do
      visit edit_admin_verification_resident_path(resident)

      fill_in :verification_resident_data,
        with: "{email: \"user@example.com\", document_number: \"#DOCUMENT_NUMBER\"}"
      click_on "Save"

      expect(page).to have_content "Resident updated successfully!"
      expect(page).to have_content "{email: \"user@example.com\", document_number: \"#DOCUMENT_NUMBER\"}"
    end
  end

  context "Destroy" do
    let!(:resident) { create(:verification_resident) }
    let!(:deleted_data) { resident.data.to_s }

    scenario "Should show successful destroy notice" do
      visit admin_verification_residents_path

      expect(page).to have_content deleted_data
      click_on "Delete"

      expect(page).to have_content "Resident removed successfully!"
      expect(page).not_to have_content deleted_data
    end
  end
end
