require "rails_helper"

feature "Admin administrators" do
  let!(:admin) { create(:administrator) }
  let!(:user) { create(:user, username: "Jose Luis Balbin") }
  let!(:user_administrator) { create(:administrator) }

  background do
    login_as(admin.user)
    visit admin_administrators_path
  end

  scenario "Can not render Add administrator link", :js do
    fill_in "name_or_email", with: user.email

    click_button "Search"

    expect(page).to have_content user.name
    expect(page).not_to have_link "Add"
  end
end
