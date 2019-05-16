require "rails_helper"

feature "Importations", type: :feature do

  let(:base_files_path) { %w[spec fixtures files local_census_records importation] }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  describe "New" do
    scenario "Should show importation form" do
      visit new_admin_local_census_records_importation_path

      expect(page).to have_field("local_census_records_importation_file", type: "file")
    end
  end

  describe "Create" do
    before { visit new_admin_local_census_records_importation_path }

    scenario "Should show success notice after successful importation" do
      within "form#new_local_census_records_importation" do
        path = base_files_path << "valid.csv"
        file = File.join(Rails.root, *path)
        attach_file("local_census_records_importation_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Local census records importation process executed successfully!"
    end

    scenario "Should show alert when file is not present" do
      within "form#new_local_census_records_importation" do
        click_button "Save"
      end

      expect(page).to have_content "can't be blank"
    end

    scenario "Should show alert when file is not supported" do
      within "form#new_local_census_records_importation" do
        path = ["spec", "fixtures", "files", "clippy.jpg"]
        file = File.join(Rails.root, *path)
        attach_file("local_census_records_importation_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Given file format is wrong. The allowed file format is: csv."
    end

    scenario "Should show successfully created local census records at created group" do
      within "form#new_local_census_records_importation" do
        path = base_files_path << "valid.csv"
        file = File.join(Rails.root, *path)
        attach_file("local_census_records_importation_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Created records (4)"
      expect(page).to have_selector("#created-local-census-records tbody tr", count: 4)
    end

    scenario "Should show invalid local census records at errored group" do
      within "form#new_local_census_records_importation" do
        path = base_files_path << "invalid.csv"
        file = File.join(Rails.root, *path)
        attach_file("local_census_records_importation_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Errored rows (4)"
      expect(page).to have_selector("#invalid-local-census-records tbody tr", count: 4)
    end

    scenario "Should show error messages inside cells at errored group" do
      within "form#new_local_census_records_importation" do
        path = base_files_path << "invalid.csv"
        file = File.join(Rails.root, *path)
        attach_file("local_census_records_importation_file", file)
        click_button "Save"
      end
      rows = all("#invalid-local-census-records tbody tr")
      expect(rows[0]).to have_content("can't be blank")
      expect(rows[1]).to have_content("can't be blank")
      expect(rows[2]).to have_content("can't be blank")
      expect(rows[3]).to have_content("can't be blank")
    end
  end
end
