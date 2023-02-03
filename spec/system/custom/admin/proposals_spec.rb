require "rails_helper"

describe "Admin proposals", :admin do
  before do
    create(:proposal, title: "Make Pluto a planet again")
    create(:proposal, title: "Build a monument to honour CONSUL developers")
  end

  scenario "Download all proposals", :no_js do
    visit admin_proposals_path(locale: :es)
    click_link "Descargar selección actual"

    expect(page.response_headers["Content-Type"]).to match(/text.csv/)
    expect(page).to have_content "Make Pluto a planet again"
    expect(page).to have_content "Build a monument"
  end

  scenario "Download ignores pagination", :no_js do
    allow(Proposal).to receive(:default_per_page).and_return(1)
    visit admin_proposals_path(locale: :es)

    expect(page).not_to have_content "Make Pluto a planet again"
    expect(page).to have_content "Build a monument"

    click_link "Descargar selección actual"

    expect(page.response_headers["Content-Type"]).to match(/text.csv/)
    expect(page).to have_content "Make Pluto a planet again"
    expect(page).to have_content "Build a monument"
  end

  scenario "Download filtered proposals", :no_js do
    visit admin_proposals_path(locale: :es, search: "pluto")

    expect(page).to have_content "Make Pluto a planet again"
    expect(page).not_to have_content "Build a monument"

    click_link "Descargar selección actual"

    expect(page.response_headers["Content-Type"]).to match(/text.csv/)
    expect(page).to have_content "Make Pluto a planet again"
    expect(page).not_to have_content "Build a monument"
  end
end
