require "rails_helper"

describe "Polls" do

  before { skip("This module has been disabled") }

  context "Public index" do
    scenario "Budget polls should not be listed" do
      poll = create(:poll)
      budget_poll = create(:poll, :for_budget)

      visit polls_path

      expect(page).to have_content(poll.name)
      expect(page).not_to have_content(budget_poll.name)
    end
  end

  context "Admin index" do
    scenario "Budget polls should not appear in the list" do
      poll = create(:poll)
      budget_poll = create(:poll, :for_budget)

      login_as(create(:administrator).user)
      visit admin_polls_path

      expect(page).to have_content(poll.name)
      expect(page).not_to have_content(budget_poll.name)
    end
  end
end
