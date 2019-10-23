require "rails_helper"

describe "Imports", type: :feature do

  let(:base_files_path) { %w[spec fixtures files verification residents import] }

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "New" do
    scenario "Should show import form" do
      visit new_admin_verification_residents_import_path

      expect(page).to have_field("verification_residents_import_file", type: "file")
    end
  end

  context "Create" do
    before { visit new_admin_verification_residents_import_path }

    scenario "Should show success notice after successful import" do
      within "form#new_verification_residents_import" do
        path = base_files_path << "valid.csv"
        file = File.join(Rails.root, *path)
        attach_file("verification_residents_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Verification residents import process executed successfully!"
    end

    scenario "Should show alert when file is not present" do
      within "form#new_verification_residents_import" do
        click_button "Save"
      end

      expect(page).to have_content "can't be blank"
    end

    scenario "Should show alert when file is not supported" do
      within "form#new_verification_residents_import" do
        path = ["spec", "fixtures", "files", "clippy.jpg"]
        file = File.join(Rails.root, *path)
        attach_file("verification_residents_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Given file format is wrong. The allowed file format is: csv."
    end

    scenario "Should show successfully created local census records at created group" do
      within "form#new_verification_residents_import" do
        path = base_files_path << "valid.csv"
        file = File.join(Rails.root, *path)
        attach_file("verification_residents_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Created records (4)"
      expect(page).to have_selector("#created-residents tbody tr", count: 4)
    end

    scenario "Should show invalid local census records at errored group" do
      within "form#new_verification_residents_import" do
        path = base_files_path << "invalid.csv"
        file = File.join(Rails.root, *path)
        attach_file("verification_residents_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Errored rows (2)"
      expect(page).to have_selector("#invalid-residents tbody tr", count: 2)
    end

    scenario "Should show error messages inside cells at errored group" do
      within "form#new_verification_residents_import" do
        path = base_files_path << "invalid.csv"
        file = File.join(Rails.root, *path)
        attach_file("verification_residents_import_file", file)
        click_button "Save"
      end
      rows = all("#invalid-residents tbody tr")
      expect(rows[0]).to have_content("has already been taken")
      expect(rows[1]).to have_content("has already been taken")
    end
  end
end
