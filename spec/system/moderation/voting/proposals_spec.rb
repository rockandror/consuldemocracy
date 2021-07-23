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

      scenario "remembering page and filter" do
        stub_const("#{Moderation::Voting::ProposalsController}::PER_PAGE", 2)
        create_list(:proposal, 4)

        visit moderation_voting_proposals_path(filter: "all", page: "2")

        accept_confirm "Are you sure?" do
          click_button "Allow vote proposals"
        end

        expect(current_url).to include("filter=all")
        expect(current_url).to include("page=2")
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_voting_proposals_path
      expect(page).not_to have_link("Pending voting review")
      expect(page).to have_link("All")
      expect(page).to have_link("Marked as voting reviewed")

      visit moderation_voting_proposals_path(filter: "all")
      within(".menu.simple") do
        expect(page).not_to have_link("All")
        expect(page).to have_link("Pending voting review")
        expect(page).to have_link("Marked as voting reviewed")
      end

      visit moderation_voting_proposals_path(filter: "pending_voting_review")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).not_to have_link("Pending voting review")
        expect(page).to have_link("Marked as voting reviewed")
      end

      visit moderation_voting_proposals_path(filter: "with_voting_reviewed")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).to have_link("Pending voting review")
        expect(page).not_to have_link("Marked as voting reviewed")
      end
    end

    scenario "Filtering proposals" do
      create(:proposal, title: "With pending voting review", enabled_voting: nil)
      create(:proposal, title: "Voting reviewed with true", enabled_voting: true )
      create(:proposal, title: "Voting reviewed with false", enabled_voting: false )

      visit moderation_voting_proposals_path(filter: "all")
      expect(page).to have_content("With pending voting review")
      expect(page).to have_content("Voting reviewed with true")
      expect(page).to have_content("Voting reviewed with false")

      visit moderation_voting_proposals_path(filter: "pending_voting_review")
      expect(page).to have_content("With pending voting review")
      expect(page).not_to have_content("Voting reviewed with true")
      expect(page).not_to have_content("Voting reviewed with false")

      visit moderation_voting_proposals_path(filter: "with_voting_reviewed")
      expect(page).not_to have_content("With pending voting review")
      expect(page).to have_content("Voting reviewed with true")
      expect(page).to have_content("Voting reviewed with false")
    end

    describe "can update enabled_voting value with allow/avoid actions" do
      let!(:proposal) { create(:proposal, enabled_voting: nil, title: "New proposal title") }

      scenario "allow vote proposals", :js do
        visit moderation_voting_proposals_path

        expect(page).to have_content "New proposal title"
        check "proposal_#{proposal.id}_check"
        accept_confirm "Are you sure?" do
          click_button "Allow vote proposals"
        end

        expect(page).to have_content "Proposals have been reviewed"
        expect(page).not_to have_content "New proposal title"

        click_link "Marked as voting reviewed"

        expect(page).to have_content "New proposal title"
      end

      scenario "avoid vote proposals", :js do
        visit moderation_voting_proposals_path

        expect(page).to have_content "New proposal title"
        check "proposal_#{proposal.id}_check"
        accept_confirm "Are you sure?" do
          click_button "Avoid vote proposals"
        end

        expect(page).to have_content "Proposals have been reviewed"
        expect(page).not_to have_content "New proposal title"

        click_link "Marked as voting reviewed"

        expect(page).to have_content "New proposal title"
      end
    end
  end
end
