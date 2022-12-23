require "rails_helper"

describe "Multitenancy management mode", :admin do
  context "when multitenancy_management_mode is set to true" do
    before { allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true) }

    scenario "renders the multitenancy layout" do
      visit admin_root_path

      within ".top-links" do
        expect(page).not_to have_content "Go back to CONSUL"
      end

      within ".top-bar" do
        expect(page).to have_css "li", count: 2
        expect(page).to have_content "My account"
        expect(page).to have_content "Sign out"
      end

      within "#admin_menu" do
        expect(page).to have_content "Settings"
        expect(page).to have_css "li", count: 1
      end

      click_link "Settings"

      within ".submenu" do
        expect(page).to have_content "Multitenancy"
        expect(page).to have_css "li", count: 1
      end
    end

    scenario "redirects root path requests to the admin root path" do
      visit root_path

      expect(page).to have_current_path admin_root_path
    end

    scenario "does not redirect other tenants to the admin root path", :seed_tenants do
      create(:tenant, schema: "mars")

      with_subdomain("mars") do
        visit root_path

        expect(page).to have_link "Debates"
      end
    end
  end

  context "when multitenancy_management_mode is set to false" do
    before { allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(false) }

    scenario "render admin layout" do
      visit admin_root_path

      within ".top-links" do
        expect(page).to have_content "Go back to CONSUL"
      end

      within ".top-bar" do
        expect(page).to have_css "li", minimum: 3
      end

      within "#admin_menu" do
        expect(page).to have_content "Settings"
        expect(page).to have_css "li", minimum: 2
      end

      click_link "Settings"

      within ".submenu" do
        expect(page).to have_content "Multitenancy"
        expect(page).to have_css "li", minimum: 2
      end
    end
  end
end
