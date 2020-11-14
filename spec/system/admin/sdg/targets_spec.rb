require "rails_helper"

describe "Targets", :js do
  before { login_as(create(:administrator).user) }

  describe "Index" do
    scenario "Visit the index" do
      goal = SDG::Goal.where(code: "1").first_or_create!
      SDG::Target.where(code: "1.1", goal: goal).first_or_create!

      visit admin_sdg_goals_path
      click_link "Targets"

      expect(page).to have_title "Administration - Targets"
      within("table") { expect(page).to have_content "By 2030, eradicate extreme poverty" }
    end
  end
end
