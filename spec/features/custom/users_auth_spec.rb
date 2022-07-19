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

      scenario "Sign in with a user with a SAML identity" do
        user = create(:user, username: "samltester", email: "tester@consul.dev", password: "My123456")
        create(:identity, uid: "ext-tester", provider: "saml", user: user)
        OmniAuth.config.add_mock(:saml, { provider: "saml", uid: "ext-tester" })

        visit new_user_session_path
        click_link "Access to the Citizen Participation Platform"

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
        click_link "Access to the Citizen Participation Platform"

        expect(page).to have_content "Successfully identified as Saml"
        within("#notice") { find("button").click }
        click_link "My account"
        expect(page).to have_field "Username", with: "tester"

        click_link "Change my credentials"
        expect(page).to have_field "Email", with: "tester@consul.dev"
      end
    end
  end
end
