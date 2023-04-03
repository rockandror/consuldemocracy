require "rails_helper"

describe "Account" do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "Last sign in" do
    scenario "Show last sign in at when setting is active" do
      Setting["security_options.last_sign_in_at"] = true
      visit account_path

      expect(page).to have_content "Last login:"
      expect(page).to have_content "from ip"
    end

    scenario "Do not show last sign in at when setting is not active" do
      visit account_path

      expect(page).not_to have_content "Last login:"
      expect(page).not_to have_content "from ip"
    end
  end
end
