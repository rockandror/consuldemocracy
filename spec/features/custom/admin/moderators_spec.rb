require "rails_helper"

feature "Admin moderators" do
  background do
    @admin = create(:administrator)
    @user  = create(:user, username: "Jose Luis Balbin")
    @moderator = create(:moderator)
    login_as(@admin.user)
    visit admin_moderators_path
  end

  scenario "Can not render Add moderator link", :js do
    fill_in "name_or_email", with: @user.email
    click_button "Search"

    expect(page).to have_content @user.name
    expect(page).not_to have_link "Add"
  end
end
