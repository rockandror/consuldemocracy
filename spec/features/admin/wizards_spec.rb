require "rails_helper"

describe "Admin Wizards" do

  before do
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  context "Admin sidebar" do
    scenario "Display wizard section on admin menu" do
      visit admin_root_path

      expect(page).to have_link("Wizard", href: admin_wizards_path)
    end
  end

  scenario "Index" do
    visit admin_wizards_path

    expect(page).to have_content("Wizard")

    expect(page).to have_content("Installation Wizard")
    expect(page).to have_content("Through this tool we present you the installation of the system.")
    expect(page).to have_link("Configure", href: new_admin_wizards_installer_path)
  end

end
