require "rails_helper"

describe "Wizard Installer" do

  let(:admin) { create(:administrator) }

  before do
    login_as(admin.user)
  end

  context "Steps" do
    scenario "Initial step" do
      visit new_admin_wizards_installer_path

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 1 of 7"
      expect(page).to have_content "Welcome to the Consul installation wizard"
      expect(page).to have_link("Get Started", href: admin_wizards_installer_path(:general_settings))
    end

    scenario "General Settings Step" do
      visit admin_wizards_installer_path(:general_settings)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 2 of 7"
      expect(page).to have_content "Global settings"
      expect(page).to have_link("Back", href: new_admin_wizards_installer_path)
      expect(page).to have_link("Next", href: admin_wizards_installer_path(:participation_process))
      within "#installer-general-settings" do
        expect(page).to have_css(".setting", count: 2)
        expect(page).to have_content "Site name"
        expect(page).to have_content "Minimum age needed to participate"
      end
    end

    scenario "Participation processes Step" do
      visit admin_wizards_installer_path(:participation_process)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 3 of 7"
      expect(page).to have_content "Participation processes"
      expect(page).to have_link("Back", href: admin_wizards_installer_path(:general_settings))
      expect(page).to have_link("Next", href: admin_wizards_installer_path(:map))
      within "#installer-participation-process" do
        expect(page).to have_css(".setting", count: 5)
        expect(page).to have_content "Debates"
        expect(page).to have_content "Proposals"
        expect(page).to have_content "Number of supports necessary for approval of a Proposal"
        expect(page).to have_content "Polls"
        expect(page).to have_content "Participatory budgeting"
      end
    end

    scenario "Map Step" do
      visit admin_wizards_installer_path(:map)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 4 of 7"
      expect(page).to have_content "Map configuration"
      expect(page).to have_link("Back", href: admin_wizards_installer_path(:participation_process))
      expect(page).to have_link("Next", href: admin_wizards_installer_path(:smtp))
      within "#installer-map" do
        expect(page).to have_css(".setting", count: 4)
        expect(page).to have_content "Proposals and budget investments geolocation"
        expect(page).to have_content "Latitude"
        expect(page).to have_content "Longitude"
        expect(page).to have_content "Zoom"
      end
    end

    scenario "Smtp Step" do
      visit admin_wizards_installer_path(:smtp)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 5 of 7"
      expect(page).to have_content "SMTP Connection"
      expect(page).to have_link("Back", href: admin_wizards_installer_path(:map))
      expect(page).to have_link("Next", href: admin_wizards_installer_path(:regional))
      within "#installer-smtp" do
        expect(page).to have_css(".setting", count: 8)
        expect(page).to have_content "SMTP Configuration"
        expect(page).to have_content "SMTP Host"
        expect(page).to have_content "SMTP Port"
        expect(page).to have_content "Domain"
        expect(page).to have_content "SMTP User"
        expect(page).to have_content "SMTP Password"
        expect(page).to have_content "SMTP Authentication"
        expect(page).to have_content "Enable SMTP TLS"
      end
    end

    scenario "Regional Step" do
      visit admin_wizards_installer_path(:regional)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 6 of 7"
      expect(page).to have_content "Languages and Time Zone"
      expect(page).to have_link("Back", href: admin_wizards_installer_path(:smtp))
      expect(page).to have_link("Next", href: admin_wizards_installer_path(:finish))
      within "#installer-regional" do
        expect(page).to have_css(".setting", count: 29)
        expect(page).to have_content "Application default locale"
        expect(page).to have_content "Application available locales"
        expect(page).to have_content "Time Zone"
      end
    end

    scenario "Finish Step" do
      visit admin_wizards_installer_path(:finish)

      expect(page).to have_content "Installation Wizard"
      expect(page).to have_content "Step 7 of 7"
      expect(page).to have_content "Wizard successfully completed"
      expect(page).to have_link("Back", href: admin_wizards_installer_path(:regional))
    end
  end
end
