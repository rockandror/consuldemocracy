require "rails_helper"

describe "Valuation budgets" do
  before do
    valuator = create(:valuator, user: create(:user, username: "Rachel", email: "rachel@valuators.org"))
    login_as(valuator.user)
  end

  context "Index" do
    scenario "Displays published and open budgets" do
      create(:budget, :finished, name: "City modernization")
      create(:budget, name: "Sports")
      create(:budget, :accepting, name: "Electrification")
      create(:budget, name: "Draft", published: false)

      visit valuation_budgets_path

      expect(page).not_to have_content("City modernization")
      expect(page).to have_content("Sports")
      expect(page).to have_content("Electrification")
      expect(page).not_to have_content("Draft")
    end

    scenario "With no budgets" do
      visit valuation_budgets_path

      expect(page).to have_content "There are no budgets"
    end
  end
end
