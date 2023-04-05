require "rails_helper"

describe "Users" do
  context "Regular authentication" do
    scenario "Avoid username-email collisions" do
      allow(Tenant.current_secrets).to receive(:security).and_return({ lockable: { maximum_attempts: 2 }})
      u1 = create(:user, username: "Spidey", email: "peter@nyc.dev", password: "greatpower")
      u2 = create(:user, username: "peter@nyc.dev", email: "venom@nyc.dev", password: "symbiote")

      visit "/"
      click_link "Sign in"
      fill_in "Email or username", with: "peter@nyc.dev"
      fill_in "Password", with: "greatpower"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."

      visit account_path

      expect(page).to have_link "My content", href: user_path(u1)

      visit "/"
      click_link "Sign out"

      expect(page).to have_content "You have been signed out successfully."

      within("#notice") { click_button "Close" }
      click_link "Sign in"
      fill_in "Email or username", with: "peter@nyc.dev"
      fill_in "Password", with: "symbiote"
      click_button "Enter"

      expect(page).not_to have_content "You have been signed in successfully."
      expect(page).to have_content "Invalid Email or username or password."

      fill_in "Email or username", with: "venom@nyc.dev"
      fill_in "Password", with: "symbiote"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."

      visit account_path

      expect(page).to have_link "My content", href: user_path(u2)
    end
  end
end
