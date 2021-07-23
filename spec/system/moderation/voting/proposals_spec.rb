require "rails_helper"

describe "Voting proposals", :js do
  before { login_as(create(:moderator).user) }

  describe "/moderation/ screen" do
    scenario "render new moties review section" do
      visit moderation_root_path

      click_link "Moties review"

      expect(page).to have_current_path(moderation_voting_proposals_path)
      expect(page).to have_selector("h2", text: "Moties review")
      expect(page).to have_content "citizen proposals cannot be found"
    end

    describe "moderate voting in bulk" do
      scenario "select all/none" do
        create_list(:proposal, 2)

        visit moderation_voting_proposals_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end
    end
  end
end
