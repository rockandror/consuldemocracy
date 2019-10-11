require "rails_helper"

describe "Admin settings" do

  before do
    @setting1 = create(:setting)
    @setting2 = create(:setting)
    @setting3 = create(:setting)
    login_as(create(:administrator).user)
  end

  scenario "Index" do
    visit admin_settings_path

    expect(page).to have_content "Configuration settings"
    expect(page).to have_content "List of general configurations to customize the application."
    expect(page).to have_link("Configure", href: admin_setting_path("configuration"))

    expect(page).to have_content "Participation processes"
    expect(page).to have_content "Selects the participation processes that will be available in the application."
    expect(page).to have_link("Configure", href: admin_setting_path("process"))

    expect(page).to have_content "Features"
    expect(page).to have_content "Activates/deactivates the different functionalities offered by the application."
    expect(page).to have_link("Configure", href: admin_setting_path("feature"))

    expect(page).to have_content "Map configuration"
    expect(page).to have_content "Allows you to update the geolocation of the application, and define the zoom of the map that will be shown to users."
    expect(page).to have_link("Configure", href: admin_setting_path("map"))

    expect(page).to have_content "Images and documents"
    expect(page).to have_content "Customize the characteristics of the application attachments."
    expect(page).to have_link("Configure", href: admin_setting_path("uploads"))

    expect(page).to have_content "Proposals dashboard"
    expect(page).to have_content "Allows configuring the main fields to offer users a control panel for their proposals."
    expect(page).to have_link("Configure", href: admin_setting_path("proposals"))

    expect(page).to have_content "Remote Census configuration"
    expect(page).to have_content "Allow configure remote census (SOAP)"
    expect(page).to have_link("Configure", href: admin_setting_path("remote_census"))

    expect(page).to have_content "Registration with social networks"
    expect(page).to have_content "Allow users to sign up with social networks (Twitter, Facebook, Google)"
    expect(page).to have_link("Configure", href: admin_setting_path("social"))

    expect(page).to have_content "Advanced Configuration"
    expect(page).to have_content "Allow update advanced configuration"
    expect(page).to have_link("Configure", href: admin_setting_path("advanced"))

    expect(page).to have_content "SMTP Configuration"
    expect(page).to have_content "Set SMTP server configuration to send emails."
    expect(page).to have_link("Configure", href: admin_setting_path("smtp"))

    expect(page).to have_content "Languages and Time Zone"
    expect(page).to have_content "Set default locale, available locales and time zone"
    expect(page).to have_link("Configure", href: admin_setting_path("regional"))

    expect(page).to have_content "SMS Configuration"
    expect(page).to have_content "Set SMS configuration to send sms for verification users."
    expect(page).to have_link("Configure", href: admin_setting_path("sms"))
  end

  scenario "Update" do
    visit admin_settings_path

    within "#configuration-section" do
      click_link "Configure"
    end
    within("#edit_setting_#{@setting2.id}") do
      fill_in "setting_#{@setting2.id}", with: "Super Users of level 2"
      click_button "Update"
    end

    expect(page).to have_content "Value updated"
  end

  describe "Show" do

    scenario "Should display configuration settings section" do
      setting = Setting.create(key: "configuration.setting_sample")

      visit admin_setting_path("configuration")

      expect(page).to have_content "Configuration settings"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display process settings section" do
      setting = Setting.create(key: "process.setting_sample")

      visit admin_setting_path("process")

      expect(page).to have_content "Participation processes"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display feature settings section" do
      setting = Setting.create(key: "feature.setting_sample")

      visit admin_setting_path("feature")

      expect(page).to have_content "Features"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display map settings section" do
      Setting["feature.map"] = true
      setting = Setting.create(key: "map.setting_sample")

      visit admin_setting_path("map")

      expect(page).to have_content "Map configuration"
      expect(page).to have_css("#edit_setting_#{setting.id}")
      expect(page).to have_content "Latitude"
      expect(page).to have_content "Longitude"
      expect(page).to have_content "Zoom"
      expect(page).to have_content "TMS(Tile Map Service) Provider"
      expect(page).to have_content "Attribution from TMS Provider"
    end

    scenario "Should display uploads settings section" do
      setting = Setting.create(key: "uploads.setting_sample")

      visit admin_setting_path("uploads")

      expect(page).to have_content "Images and documents"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display proposals settings section" do
      setting = Setting.create(key: "proposals.setting_sample")

      visit admin_setting_path("proposals")

      expect(page).to have_content "Proposals dashboard"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display remote_census settings section" do
      Setting["feature.remote_census"] = true
      setting = Setting.create(key: "remote_census.response.setting_sample")

      visit admin_setting_path("remote_census")

      expect(page).to have_content "Remote Census configuration"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display social settings section" do
      setting = Setting.create(key: "social.twitter.setting_sample")

      visit admin_setting_path("social")

      expect(page).to have_content "Registration with social networks"
      expect(page).to have_content "Twitter"
      expect(page).to have_content "Facebook"
      expect(page).to have_content "Google"
      expect(page).to have_content "Note: For changes to this section to take effect correctly, contact your system administrator to restart all services that are using the application."
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display smtp settings section" do
      setting = Setting.create(key: "smtp.setting_sample")
      Setting["feature.smtp_configuration"] = true

      visit admin_setting_path("smtp")

      expect(page).to have_content "SMTP Configuration"
      expect(page).to have_content "SMTP Host"
      expect(page).to have_content "SMTP Port"
      expect(page).to have_content "Domain"
      expect(page).to have_content "SMTP User"
      expect(page).to have_content "SMTP Password"
      expect(page).to have_content "SMTP Authentication"
      expect(page).to have_content "Enable SMTP TLS"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display regional settings section" do
      setting = Setting.create(key: "regional.default_locale.setting_sample")

      visit admin_setting_path("regional")

      expect(page).to have_content "Application default locale"
      expect(page).to have_content "Application available locales"
      expect(page).to have_content "Time Zone"
      expect(page).to have_css("#edit_setting_#{setting.id}")
    end

    scenario "Should display with disabled style default_locale as available_locales feature" do
      default_locale = Setting.find_by(key: "regional.default_locale.key").value
      available_locale_setting_from_default_locale = Setting.find_by(key: "regional.available_locale.#{default_locale}")

      visit admin_setting_path("regional")

      within "#edit_setting_#{available_locale_setting_from_default_locale.id}" do
        expect(find("input[name='commit'][type='submit']").disabled?).to be true
      end
    end

  end

  describe "Update map" do

    scenario "Should not be able when map feature deactivated" do
      Setting["feature.map"] = false

      visit admin_setting_path("map")

      expect(page).to have_content "To show the map to users you must enable " \
                                   '"Proposals and budget investments geolocation" ' \
                                   'on "Features" tab.'
      expect(page).not_to have_css("#admin-map")
    end

    scenario "Should be able when map feature activated" do
      Setting["feature.map"] = true

      visit admin_setting_path("map")

      expect(page).to have_css("#admin-map")
      expect(page).not_to have_content "To show the map to users you must enable " \
                                       '"Proposals and budget investments geolocation" ' \
                                       'on "Features" tab.'
    end

    scenario "Should show successful notice" do
      Setting["feature.map"] = true

      visit admin_setting_path("map")

      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should display marker by default", :js do
      Setting["feature.map"] = true

      visit admin_setting_path("map")

      expect(find("#latitude", visible: false).value).to eq "51.48"
      expect(find("#longitude", visible: false).value).to eq "0.0"
    end

    scenario "Should update marker", :js do
      Setting["feature.map"] = true

      visit admin_setting_path("map")

      find("#admin-map").click
      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
      expect(find("#latitude", visible: false).value).not_to eq "51.48"
    end

  end

  describe "Update content types" do

    scenario "stores the correct mime types", :js do
      setting = Setting.find_by(key: "uploads.images.content_types")
      setting.update(value: "image/png")

      visit admin_setting_path("uploads")

      within "#edit_setting_#{setting.id}" do
        expect(find("#png")).to be_checked
        expect(find("#jpg")).not_to be_checked
        expect(find("#gif")).not_to be_checked

        check "gif"

        click_button "Update"
      end

      expect(page).to have_content "Value updated"
      expect(Setting["uploads.images.content_types"]).to include "image/png"
      expect(Setting["uploads.images.content_types"]).to include "image/gif"

      within "#uploads-section" do
        click_link "Configure"
      end

      within "#edit_setting_#{setting.id}" do
        expect(find("#png")).to be_checked
        expect(find("#gif")).to be_checked
        expect(find("#jpg")).not_to be_checked
      end
    end

  end

  describe "Update Remote Census Configuration" do

    before do
      Setting["feature.remote_census"] = true
    end

    scenario "Should not be able when remote census feature deactivated" do
      Setting["feature.remote_census"] = nil

      visit admin_setting_path("remote_census")

      expect(page).to have_content 'To configure remote census (SOAP) you must enable ' \
                                   '"Configure connection to remote census (SOAP)" ' \
                                   'on "Features" tab.'
    end

    scenario "Should be able when remote census feature activated" do
      visit admin_setting_path("remote_census")

      expect(page).to have_content("General Information")
      expect(page).to have_content("Request Data")
      expect(page).to have_content("Response Data")
      expect(page).not_to have_content 'To configure remote census (SOAP) you must enable ' \
                                       '"Configure connection to remote census (SOAP)" ' \
                                       'on "Features" tab.'
    end

  end

  describe "Update Regional Settings" do

    scenario "Should update default_locale", :js do
      setting = Setting.find_by(key: "regional.default_locale.key")

      visit admin_setting_path("regional")

      within("#edit_setting_#{setting.id}") do
        select("Español", from: "setting_value")
        click_button "Update"
      end

      expect(page).to have_content "Value updated"
      expect(I18n.default_locale).to eq :es
    end

    scenario "Should update available_locales", :js do
      setting = Setting.find_by(key: "regional.available_locale.es")
      visit admin_setting_path("regional")
      expect(I18n.available_locales).to include :es

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content "Value updated"
      expect(I18n.available_locales).not_to include :es
    end

    scenario "Should update time_zone" do
      setting = Setting.find_by(key: "regional.time_zone.key")
      visit admin_setting_path("regional")

      within("#edit_setting_#{setting.id}") do
        select("(GMT-05:00) Lima", from: "setting_value")
        click_button "Update"
      end

      expect(page).to have_content "Value updated"
      expect(Time.zone.name).to eq "Lima"
    end

  end

  describe "Skip verification" do

    scenario "deactivate skip verification", :js do
      Setting["feature.user.skip_verification"] = "true"
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_setting_path("feature")

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content "Value updated"
    end

    scenario "activate skip verification", :js do
      Setting["feature.user.skip_verification"] = nil
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_setting_path("feature")

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content "Value updated"

      Setting["feature.user.skip_verification"] = nil
    end

  end

end
