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

    describe "review voting in bulk" do
      scenario "allows to select all/none proposals" do
        create_list(:proposal, 2)

        visit moderation_voting_proposals_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario "allow to enable proposal voting" do
        proposal = create(:proposal, voting_enabled: nil, title: "New proposal title")
        visit moderation_voting_proposals_path

        expect(page).to have_content "New proposal title"
        check "proposal_#{proposal.id}_check"
        accept_confirm "Are you sure?" do
          click_button "Enable voting"
        end

        expect(page).to have_content "Proposals have been reviewed"
        expect(page).not_to have_content "New proposal title"

        click_link "In voting"

        expect(page).to have_content "New proposal title"
      end

      scenario "allows to disable proposal voting" do
        proposal = create(:proposal, voting_enabled: nil, title: "New proposal title")
        visit moderation_voting_proposals_path

        expect(page).to have_content "New proposal title"
        check "proposal_#{proposal.id}_check"
        accept_confirm "Are you sure?" do
          click_button "Disable voting"
        end

        expect(page).to have_content "Proposals have been reviewed"
        expect(page).not_to have_content "New proposal title"

        click_link "Blocked"

        expect(page).to have_content "New proposal title"
      end

      scenario "allows to remove proposals reviews" do
        proposal = create(:proposal, voting_enabled: true, title: "New proposal title")
        visit moderation_voting_proposals_path(filter: "voting_enabled")

        expect(page).to have_content "New proposal title"

        check "proposal_#{proposal.id}_check"
        accept_confirm "Are you sure?" do
          click_button "Remove review"
        end

        expect(page).to have_content "Proposals have been reviewed"
        expect(page).not_to have_content "New proposal title"

        click_link "To review"

        expect(page).to have_content "New proposal title"
      end

      scenario "Do not render remove review button when filter is voting_pending" do
        visit moderation_voting_proposals_path(filter: "voting_pending")

        expect(page).not_to have_button "Remove review"

        click_link "In voting"

        expect(page).to have_button "Remove review"
      end
    end
  end

  describe "voting review mailers" do
    before do
      ActionMailer::Base.deliveries.clear
    end

    scenario "send 'voting review' email after create proposal" do
      login_as(create(:user, email: "new_email@user.com"))
      visit new_proposal_path

      fill_in "Proposal title", with: "Help refugees"
      fill_in "Proposal details", with: "Madrid (Spain) - 12/12/2022"
      fill_in_ckeditor "Proposal summary", with: "In summary, what we want is..."
      fill_in_ckeditor "Proposal text", with: "This is very important because..."
      fill_in "proposal_responsible_name", with: "Isabel Garcia"
      check "proposal_terms_of_service"

      click_button "Create proposal"
      expect(page).to have_content "Proposal created successfully."

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq(["new_email@user.com"])
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Thank you for creating a proposal!")
    end
  end
end
