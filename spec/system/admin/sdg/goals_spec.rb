require "rails_helper"

describe "Goals", :js do
  before { login_as(create(:administrator).user) }

  describe "Index" do
    scenario "Visit the index" do
      SDG::Goal.where(code: "1").first_or_create!

      visit admin_root_path

      within("#side_menu") do
        click_link "SDG content"
        click_link "Goals"
      end

      expect(page).to have_title "Administration - Goals"
      within("table") { expect(page).to have_content "No Poverty" }
    end
  end
end
