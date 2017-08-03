require 'rails_helper'

feature "Admin city map" do

  context "Feature activation" do

    scenario "Should not be able when feature deactivated" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_root_path

      within "#side_menu" do
        expect(page).not_to have_link "Custom city map", href: admin_site_customization_city_map_edit_path
      end
    end

    scenario "Should be able when feature deactivated" do
      admin = create(:administrator).user
      login_as(admin)
      Setting['feature.map'] = true
      visit admin_root_path

      within "#side_menu" do
        expect(page).to have_link "Custom city map", href: admin_site_customization_city_map_edit_path
      end
    end

  end

  context "Edit" do

    scenario "Should not be able to normal users" do
      user = create(:user)
      login_as(user)
      visit admin_site_customization_city_map_edit_path

      expect(page).not_to have_content "Application map center"
    end

    scenario "Should be able to administrators" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      expect(page).to have_content "Application map center"
    end

    scenario "Should have inputs prefilled correctly", :js do
      city_map = SiteCustomization::CityMap.find
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      expect(find('#site_customization_city_map_address').value).to eq city_map.address
      expect(find('#site_customization_city_map_latitude').value).to eq city_map.latitude.to_s
      expect(find('#site_customization_city_map_longitude').value).to eq city_map.longitude.to_s
      expect(find('#site_customization_city_map_zoom').value).to eq city_map.zoom.to_s
    end

  end

  context "Update" do

    scenario "Should show validations errors" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      fill_in :site_customization_city_map_address, with: ""
      click_on "Save map configuration"

      expect(page).to have_content "1 error prevented map from being saved"
      expect(page).to have_content "address can't be blank"
    end

    scenario "Should show error notice when there is validation errors" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      fill_in :site_customization_city_map_address, with: ""
      click_on "Save map configuration"

      expect(page).to have_content "Cannot update map configuration. Check form errors and try again."
      expect(page).to have_content "1 error prevented map from being saved"
      expect(page).to have_content "address can't be blank"
    end

    scenario "Should show successful notice" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      click_on "Save map configuration"

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should update latitude, longitude and zoom fields after address autoomplete selection", :js do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_site_customization_city_map_edit_path

      choose_autocomplete :site_customization_city_map_address, with: "Madrid", select: "Community of Madrid, Spain"

      expect(find('#site_customization_city_map_address').value).to eq "Community of Madrid, Spain"
      expect(find('#site_customization_city_map_latitude').value).to eq "40.5248319"
      expect(find('#site_customization_city_map_longitude').value).to eq "-3.77156277545181"
    end

  end

end