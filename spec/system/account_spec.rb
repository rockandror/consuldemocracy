require "rails_helper"

describe "Account" do
  let(:user) { create(:user, username: "Manuela Colau") }

  before do
    login_as(user)
  end

  scenario "Show" do
    visit root_path

    click_link "My account"

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_selector("input[value='Manuela Colau']")
    expect(page).to have_selector(avatar("Manuela Colau"), count: 1)
  end

  scenario "Show organization" do
    create(:organization, user: user, name: "Manuela Corp")

    visit account_path

    expect(page).to have_selector("input[value='Manuela Corp']")
    expect(page).not_to have_selector("input[value='Manuela Colau']")

    expect(page).to have_selector(avatar("Manuela Corp"), count: 1)
  end

  scenario "Edit" do
    visit account_path

    fill_in "account_username", with: "Larry Bird"
    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry Bird']")
  end

  scenario "Edit email address" do
    visit account_path

    click_link "Change my credentials"
    fill_in "user_email", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    fill_in "user_password_confirmation", with: "new_password"
    fill_in "user_current_password", with: "judgmentday"

    click_button "Update"

    logout
    visit new_user_session_path(sign_in_form: "1")
    fill_in "user_login", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    click_button "Enter"

    expect(page).to have_content "You have been signed in successfully."

    visit account_path
    click_link "Change my credentials"
    expect(page).to have_selector("input[value='new_user_email@example.com']")
  end

  scenario "Edit Organization" do
    create(:organization, user: user, name: "Manuela Corp")
    visit account_path

    fill_in "account_organization_attributes_name", with: "Google"

    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Google']")
  end

  context "Option to display badge for official position" do
    scenario "Users with official position of level 2 and above" do
      official_user2 = create(:user, official_level: 2)
      official_user3 = create(:user, official_level: 3)

      login_as(official_user2)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"

      login_as(official_user3)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"
    end
  end

  scenario "Errors on edit" do
    visit account_path

    fill_in "account_username", with: ""
    click_button "Save changes"

    expect(page).to have_content error_message
  end

  scenario "Errors editing credentials" do
    visit root_path

    click_link "My account"

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_link("Change my credentials")
    click_link "Change my credentials"
    click_button "Update"

    expect(page).to have_content error_message
  end

  scenario "Erasing account" do
    visit account_path

    click_link "Erase my account"

    fill_in "user_erase_reason", with: "a test"

    click_button "Erase my account"

    expect(page).to have_content "Goodbye! Your account has been cancelled. We hope to see you again soon."

    login_through_form_as(user)

    expect(page).to have_content "Invalid Email or username or password"
  end
end
