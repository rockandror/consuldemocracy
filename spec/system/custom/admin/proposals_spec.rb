require "rails_helper"

describe "Admin proposals", :admin do
  scenario "Download all proposals", :no_js do
    create(:proposal, title: "Make Pluto a planet again")
    create(:proposal, title: "Build a monument to honour CONSUL developers")

    visit admin_proposals_path(locale: :es)
    click_link "Exportar todas las propuestas"

    expect(page.response_headers["Content-Type"]).to match(/text.csv/)
    expect(page).to have_content "Make Pluto a planet again"
    expect(page).to have_content "Build a monument"
  end
end
