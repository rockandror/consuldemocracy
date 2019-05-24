require "rails_helper"

feature "Admin census locals" do

  background do
    login_as(create(:administrator).user)
  end

  context "Index" do
    let!(:census_local) { create(:census_local) }

    scenario "Should show empty message when no local census records exists" do
      Census::Local.delete_all
      visit admin_census_locals_path

      expect(page).to have_content("There are no local census records.")
    end

    scenario "Should show existing local census records" do
      visit admin_census_locals_path

      expect(page).to have_content(census_local.document_type)
      expect(page).to have_content(census_local.document_number)
      expect(page).to have_content(census_local.date_of_birth)
      expect(page).to have_content(census_local.postal_code)
    end

    scenario "Should show edit and destroy actions for each record" do
      visit admin_census_locals_path

      within "#census_local_#{census_local.id}" do
        expect(page).to have_link "Edit"
        expect(page).to have_link "Delete"
      end
    end

    scenario "Should show page entries info" do
      visit admin_census_locals_path

      expect(page).to have_content("There is 1 local census record")
    end

    scenario "Should show paginator" do
      create_list(:census_local, 25)
      visit admin_census_locals_path

      within ".pagination" do
        expect(page).to have_link("2")
      end
    end

    context "Search" do
      background do
        create(:census_local, document_number: "X66777888" )
      end

      scenario "Should show matching records by document number at first visit" do
        visit admin_census_locals_path(search: "X66777888")

        expect(page).to have_content "X66777888"
        expect(page).not_to have_content census_local.document_number
      end

      scenario "Should show matching records by document number", :js do
        visit admin_census_locals_path

        fill_in :search, with: "X66777888"
        click_on "Search"

        expect(page).to have_content "X66777888"
        expect(page).not_to have_content census_local.document_number
      end
    end
  end

  context "Create" do
    scenario "Should show validation errors" do
      visit new_admin_census_local_path

      click_on "Save"

      expect(page).to have_content "4 errors prevented this Local Census Record from being saved."
      expect(page).to have_content "can't be blank", count: 4
    end

    scenario "Should show successful notice after create valid record" do
      visit new_admin_census_local_path

      fill_in :census_local_document_type, with: "DNI"
      fill_in :census_local_document_number, with: "#DOCUMENT"
      select "1982" , from: :census_local_date_of_birth_1i
      select "July" , from: :census_local_date_of_birth_2i
      select "7" , from: :census_local_date_of_birth_3i
      fill_in :census_local_postal_code, with: "07003"
      click_on "Save"

      expect(page).to have_content "New local census record created successfully!"
      expect(page).to have_content "DNI"
      expect(page).to have_content "#DOCUMENT"
      expect(page).to have_content "1982-07-07"
      expect(page).to have_content "07003"
    end
  end
end
