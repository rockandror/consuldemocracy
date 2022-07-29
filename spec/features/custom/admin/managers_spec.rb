require "rails_helper"

feature "Admin managers" do
  background do
    @admin = create(:administrator)
    @user  = create(:user)
    @manager = create(:manager)
    login_as(@admin.user)
    visit admin_managers_path
  end

  scenario "Can not render Add manager link", :js do
    fill_in "name_or_email", with: @user.email
    click_button "Search"

    expect(page).to have_content @user.name
    expect(page).not_to have_link "Add"
  end
end
