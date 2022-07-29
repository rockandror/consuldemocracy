require "rails_helper"

feature "Admin valuators" do

  background do
    @admin    = create(:administrator)
    @user     = create(:user, username: "Jose Luis Balbin")
    @valuator = create(:valuator)
    login_as(@admin.user)
    visit admin_valuators_path
  end

  scenario "Can not render Add valuator link", :js do
    fill_in "name_or_email", with: @user.email
    click_button "Search"

    expect(page).to have_content(@user.name)
    expect(page).not_to have_link "Add to valuators"
  end
end
