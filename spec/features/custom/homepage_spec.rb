require "rails_helper"

describe "Home" do
  before { allow(I18n).to receive(:default_locale).and_return(:es) }

  scenario "has top links" do
    load Rails.root.join("db/custom_seeds.rb")

    visit root_path

    within ".top-links" do
      expect(page).to have_link "Gobierno abierto"
      expect(page).to have_link "Transparencia"
      expect(page).to have_link "Datos abiertos"
      expect(page).to have_link "Participación ciudadana"
    end
  end

  describe "navigation" do
    scenario "has a link to the home page" do
      visit root_path

      within "#navigation_bar" do
        expect(page).to have_link "Portada"
      end
    end
  end

  describe "footer" do
    scenario "has the footer content" do
      visit root_path

      within "footer" do
        within ".sites-info" do
          expect(page).to have_link "Gobierno abierto"
          expect(page).to have_link "Transparencia"
          expect(page).to have_link "Datos abiertos"
        end

        within ".gob-logos" do
          expect(page).to have_css "img[alt='Canarias Avanza con Europa']"
          expect(page).to have_content "Fondo Europeo de Desarrollo Regional"
        end

        within ".subfooter" do
          expect(page).to have_content "Gobierno de Canarias, #{Date.current.year}"
          expect(page).to have_link "Accesibilidad"
          expect(page).to have_link "Condiciones de uso"
          expect(page).to have_link "Cookies y privacidad"
          expect(page).to have_link "Contacto"
          expect(page).to have_link "Aviso legal"
        end
      end
    end
  end
end
