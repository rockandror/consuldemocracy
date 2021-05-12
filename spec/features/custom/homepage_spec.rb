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

  describe "header card" do
    scenario "renders default texts without a card" do
      visit root_path

      within ".header-section" do
        within ".header-title" do
          expect(page).to have_text "Slogan del portal", exact: true
        end

        within ".header-description" do
          expect(page).to have_text "Bienvenid@ al portal"
        end

        expect(page).to have_link "Regístrate"
      end
    end

    scenario "renders texts in the header card" do
      create(:widget_card, header: true,
             title: "Title",
             description: "Description"
            )

      visit root_path

      within ".header-section" do
        within ".header-title" do
          expect(page).to have_text "Title", exact: true
        end

        within ".header-description" do
          expect(page).to have_text "Description", exact: true
        end
      end
    end

    scenario "renders default texts with an empty card" do
      create(:widget_card, header: true,
             title: "",
             description: ""
            )

      visit root_path

      within ".header-section" do
        within ".header-title" do
          expect(page).to have_text "Slogan del portal", exact: true
        end

        within ".header-description" do
          expect(page).to have_text "Bienvenid@ al portal"
        end

        expect(page).to have_link "Regístrate"
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

    describe "social" do
      scenario "renders a list of links when settings are defined" do
        Setting["twitter_handle"] = "myhandle"

        visit root_path

        within "footer" do
          expect(page).to have_selector ".social ul"
        end
      end

      scenario "does not render an empty list when settings are not defined" do
        Setting["twitter_handle"] = ""
        Setting["facebook_handle"] = ""
        Setting["blog_url"] = ""
        Setting["youtube_handle"] = ""
        Setting["telegram_handle"] = ""
        Setting["instagram_handle"] = ""

        visit root_path

        within "footer" do
          expect(page).not_to have_selector ".social ul"
        end
      end
    end
  end
end
