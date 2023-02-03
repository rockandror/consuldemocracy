require "rails_helper"

describe "Custom Pages" do
  scenario "Related custom pages to main links section can be accessed" do
    visit root_path(locale: :es)

    click_link "Cabildo Abierto"

    expect(page).to have_selector "h1", text: "¿Qué es cabildoabierto.tenerife.es?"

    click_link "Participación y colaboración"

    expect(page).to have_selector "h1", text: "Conoce lo que hacemos"

    click_link "Ética Pública"

    expect(page).to have_selector "h1", text: "Código de Buen Gobierno"
  end
end
