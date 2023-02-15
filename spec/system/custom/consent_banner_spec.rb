require "rails_helper"

describe "Consent banner" do
  scenario "Is shown in public pages" do
    visit root_path

    within ".cookies-eu" do
      expect(page).to have_button("OK")
    end

    visit debates_path

    within ".cookies-eu" do
      expect(page).to have_button("OK")
    end

    visit polls_path

    within ".cookies-eu" do
      expect(page).to have_button("OK")
    end
  end

  scenario "Is hidden when accepted and when browsing other pages" do
    visit root_path

    within ".cookies-eu" do
      click_button "OK"
    end

    expect(page).not_to have_css(".cookies-eu")

    visit root_path

    expect(page).not_to have_css(".cookies-eu")

    visit debates_path

    expect(page).not_to have_css(".cookies-eu")

    visit polls_path

    expect(page).not_to have_css(".cookies-eu")
  end
end
