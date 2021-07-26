require "rails_helper"

describe "Proposals voting", :js do
  before { login_as(create(:moderator).user) }

  scenario "renders voting moderation section" do
    visit moderation_root_path

    click_link "Proposals voting"

    expect(page).to have_current_path(moderation_voting_proposals_path)
    expect(page).to have_selector("h2", text: "Proposals voting")
  end

  describe "Index" do
    scenario "highlights the current filter" do
      visit moderation_voting_proposals_path

      expect(page).not_to have_link("To review")
      expect(page).to have_link("All")
      expect(page).to have_link("In voting")
      expect(page).to have_link("Blocked")

      visit moderation_voting_proposals_path(filter: "all")

      within(".menu.simple") do
        expect(page).to have_link("To review")
        expect(page).not_to have_link("All")
        expect(page).to have_link("In voting")
        expect(page).to have_link("Blocked")
      end

      visit moderation_voting_proposals_path(filter: "voting_enabled")

      within(".menu.simple") do
        expect(page).to have_link("To review")
        expect(page).to have_link("All")
        expect(page).not_to have_link("In voting")
        expect(page).to have_link("Blocked")
      end

      visit moderation_voting_proposals_path(filter: "voting_disabled")

      within(".menu.simple") do
        expect(page).to have_link("To review")
        expect(page).to have_link("All")
        expect(page).to have_link("In voting")
        expect(page).not_to have_link("Blocked")
      end
    end

    scenario "filtering proposals" do
      create(:proposal, title: "To review", voting_enabled: nil)
      create(:proposal, title: "In voting", voting_enabled: true)
      create(:proposal, title: "Blocked", voting_enabled: false)

      visit moderation_voting_proposals_path(filter: "all")

      within ".proposals" do
        expect(page).to have_content("To review")
        expect(page).to have_content("In voting")
        expect(page).to have_content("Blocked")
      end

      visit moderation_voting_proposals_path(filter: "voting_pending")

      within ".proposals" do
        expect(page).to have_content("To review")
        expect(page).not_to have_content("In voting")
        expect(page).not_to have_content("Blocked")
      end

      visit moderation_voting_proposals_path(filter: "voting_enabled")

      within ".proposals" do
        expect(page).not_to have_content("To review")
        expect(page).to have_content("In voting")
        expect(page).not_to have_content("Blocked")
      end

      visit moderation_voting_proposals_path(filter: "voting_disabled")

      within ".proposals" do
        expect(page).not_to have_content("To review")
        expect(page).not_to have_content("In voting")
        expect(page).to have_content("Blocked")
      end
    end

    describe "Order" do
      scenario "when browsing pending to review proposals shows oldest first" do
        create(:proposal, title: "Old proposal", created_at: 1.month.ago, voting_enabled: nil)
        create(:proposal, title: "Recent proposal", created_at: 1.week.ago, voting_enabled: nil)
        create(:proposal, title: "New proposal", created_at: 1.day.ago, voting_enabled: nil)

        visit moderation_voting_proposals_path

        expect("Old proposal").to appear_before("Recent proposal")
        expect("Recent proposal").to appear_before("New proposal")
      end

      scenario "when browsing in voting proposals shows newest first" do
        create(:proposal, title: "Old proposal", created_at: 1.month.ago, voting_enabled: true)
        create(:proposal, title: "Recent proposal", created_at: 1.week.ago, voting_enabled: true)
        create(:proposal, title: "New proposal", created_at: 1.day.ago, voting_enabled: true)

        visit moderation_voting_proposals_path(filter: "voting_enabled")

        expect("New proposal").to appear_before("Recent proposal")
        expect("Recent proposal").to appear_before("Old proposal")
      end

      scenario "when browsing blocked proposals shows newest first" do
        create(:proposal, title: "Old proposal", created_at: 1.month.ago, voting_enabled: false)
        create(:proposal, title: "Recent proposal", created_at: 1.week.ago, voting_enabled: false)
        create(:proposal, title: "New proposal", created_at: 1.day.ago, voting_enabled: false)

        visit moderation_voting_proposals_path(filter: "voting_disabled")

        expect("New proposal").to appear_before("Recent proposal")
        expect("Recent proposal").to appear_before("Old proposal")
      end
    end
  end
end
