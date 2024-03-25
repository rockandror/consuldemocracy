require "rails_helper"

describe "Account" do
  let(:geozone) { create(:geozone, name: "Village") }
  let(:user) do
    create(:user, gender: :male, geozone: geozone, date_of_birth: Date.parse("01/02/2000"))
  end

  before do
    login_as(user)
  end

  context "With date_of_birth, gender and geozone fields" do
    scenario "Show" do
      visit root_path

      click_link "My account"

      expect(page).to have_select("account_gender", selected: "Male")
      expect(page).to have_select("account_geozone_id", selected: "Village")
      expect(page).to have_select("account_date_of_birth_3i", selected: "1")
      expect(page).to have_select("account_date_of_birth_2i", selected: "February")
      expect(page).to have_select("account_date_of_birth_1i", selected: "2000")
    end

    scenario "Edit" do
      create(:geozone, name: "City")
      visit account_path

      select "City", from: "account_geozone_id"
      select "Female", from: "account_gender"
      select "1999", from: "account_date_of_birth_1i"
      select "January", from: "account_date_of_birth_2i"
      select "2", from: "account_date_of_birth_3i"

      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_select("account_gender", selected: "Female")
      expect(page).to have_select("account_geozone_id", selected: "City")
      expect(page).to have_select("account_date_of_birth_3i", selected: "2")
      expect(page).to have_select("account_date_of_birth_2i", selected: "January")
      expect(page).to have_select("account_date_of_birth_1i", selected: "1999")
    end
  end
end
