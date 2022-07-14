require "rails_helper"

feature "Users" do
  context "OAuth authentication" do
    context "Saml" do

      before do
        Setting["feature.saml_login"] = true
      end

      after do
        Setting["feature.saml_login"] = false
      end

      describe "Include SAML section" do
        scenario "on sign in page" do
          visit root_path

          click_link "Register"

          expect(page).to have_content "Only if you are staff of the Government of the Canary Islands:"
          expect(page).to have_link "Access through CAS"
        end

        scenario "on sign up page" do
          visit root_path

          click_link "Sign in"

          expect(page).to have_content "Only if you are staff of the Government of the Canary Islands:"
          expect(page).to have_link "Access through CAS"
        end
      end
    end
  end

  context "#expire_password_after" do
    scenario "Sign in, admin with password expired" do
      user = create(:user)
      admin = create(:administrator, user: user)
      travel 1.year + 1.day

      login_as(admin.user)
      visit root_path

      expect(page).to have_content "Your password is expired"
    end

    scenario "Sign in, admin without password expired" do
      user = create(:user)
      admin = create(:administrator, user: user)
      travel 1.year - 1.day

      login_as(admin.user)
      visit root_path

      expect(page).not_to have_content "Your password is expired"
    end

    scenario "Sign in, user with password expired" do
      user = create(:user)
      travel 1.year + 1.day

      login_as(user)
      visit root_path

      expect(page).to have_content "Your password is expired"
    end

    scenario "Sign in, user without password expired" do
      user = create(:user)
      travel 1.year - 1.day

      login_as(user)
      visit root_path

      expect(page).not_to have_content "Your password is expired"
    end

    scenario "Admin with password expired trying to use same password" do
      user = create(:user, password: "Admin123456789")
      admin = create(:administrator, user: user)
      travel 1.year + 1.day

      login_as(admin.user)
      visit root_path

      expect(page).to have_content "Your password is expired"

      fill_in "user_current_password", with: "JudgmentDay1234"
      fill_in "user_password", with: "Admin123456789"
      fill_in "user_password_confirmation", with: "Admin123456789"
      click_button "Change your password"

      expect(page).to have_content "must be different than the current password."
    end
  end
end
