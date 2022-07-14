require "rails_helper"

feature "Users", :js do
  context "OAuth authentication" do
    context "Saml" do
      before do
        Setting["feature.saml_login"] = true
      end

      after do
        Setting["feature.saml_login"] = false
      end

      scenario "Sign up with a confirmed email" do
        saml_hash = {
          provider: "saml",
          uid: "ext-tester",
          info: {
            name: "samltester",
            email: "tester@consul.dev",
            verified: "1"
          }
        }
        OmniAuth.config.add_mock(:saml, saml_hash)

        visit new_user_registration_path
        click_link "Access through CAS"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { find("button").click }
        click_link "My account"
        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my credentials"
        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign up with an unconfirmed email" do
        saml_hash = {
          provider: "saml",
          uid: "ext-tester",
          info: {
            name: "samltester",
            email: "tester@consul.dev"
          }
        }
        OmniAuth.config.add_mock(:saml, saml_hash)

        visit new_user_registration_path
        click_link "Access through CAS"

        expect(page).to have_content "To continue, please click on the confirmation link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"
        expect(page).to have_current_path new_user_session_path

        click_link "Access through CAS"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { find("button").click }
        click_link "My account"
        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my credentials"
        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user with a SAML identity" do
        user = create(:user, username: "samltester", email: "tester@consul.dev", password: "My123456")
        create(:identity, uid: "ext-tester", provider: "saml", user: user)
        OmniAuth.config.add_mock(:saml, { provider: "saml", uid: "ext-tester" })

        visit new_user_session_path
        click_link "Access through CAS"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { find("button").click }
        click_link "My account"
        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my credentials"
        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user without a SAML identity keeps the username" do
        create(:user, username: "tester", email: "tester@consul.dev", password: "My123456")
        saml_hash = {
          provider: "saml",
          uid: "ext-tester",
          info: {
            name: "samltester",
            email: "tester@consul.dev",
            verified: "1"
          }
        }
        OmniAuth.config.add_mock(:saml, saml_hash)

        visit new_user_session_path
        click_link "Access through CAS"

        expect(page).to have_content "Successfully identified as Saml"
        within("#notice") { find("button").click }
        click_link "My account"
        expect(page).to have_field "Username", with: "tester"

        click_link "Change my credentials"
        expect(page).to have_field "Email", with: "tester@consul.dev"
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

  describe "Sign up" do
    scenario "Reject password without complexity" do
      visit new_user_registration_path

      fill_in "Username",         with: "Juan Romero"
      fill_in "Email",            with: "juan@consul.dev"
      fill_in "Password",         with: "without_uppercase_and_digits"
      fill_in "Confirm password", with: "without_uppercase_and_digits"
      check "user_terms_of_service"

      click_button "Register"

      expect(page).to have_content "must contain big, small letters and digits"
    end
  end
end
