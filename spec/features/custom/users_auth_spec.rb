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
end
