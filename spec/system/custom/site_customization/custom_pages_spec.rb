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

  describe "Menu" do
    context "Custom pages related to main links" do
      scenario "always render menu" do
        visit root_path(locale: :es)
        click_link "Cabildo Abierto"

        within ".menu-title" do
          expect(page).to have_content "Cabildo Abierto"
        end

        within ".menu-sections" do
          expect(page).to have_link "¿Qué es cabildoabierto.tenerife.es?"
        end

        click_link "Participación y colaboración"

        within ".menu-title" do
          expect(page).to have_content "Participación y Colaboración Ciudadana"
        end

        within ".menu-sections" do
          expect(page).to have_link "Conoce lo que hacemos"
        end

        click_link "Ética Pública"

        within ".menu-title" do
          expect(page).to have_content "Ética Pública"
        end

        within ".menu-sections" do
          expect(page).to have_link "Código de Buen Gobierno"
        end
      end
    end

    context "Other custom pages" do
      scenario "only renders the menu section when the slugs contain '_cabildo_', '_participacion_' or '_etica_'" do
        create(:site_customization_page, :published, slug: "_cabildo_any-slug", title: "Slug con Cabildo")
        create(:site_customization_page, :published, slug: "new_slug")

        visit page_path("_cabildo_any-slug", locale: :es)

        within ".menu-title" do
          expect(page).to have_content "Cabildo Abierto"
        end

        within ".menu-sections" do
          expect(page).to have_link "¿Qué es cabildoabierto.tenerife.es?"
          expect(page).to have_link "Slug con Cabildo"
        end

        visit page_path("new_slug", locale: :es)

        expect(page).not_to have_css ".menu-title"
        expect(page).not_to have_css ".menu-sections"
      end
    end

    describe "Menu contents" do
      before do
        create(:site_customization_page, :published,
          slug: "_cabildo_any-slug",
          title: "Cabildo related page"
        )
        create(:site_customization_page, :published,
          slug: "_participacion_any-slug",
          title: "Participation related page"
        )
        create(:site_customization_page, :published,
          slug: "_etica_any-slug",
          title: "Ethics related page"
        )
        create(:site_customization_page, :published,
          slug: "_other_any-slug",
          title: "Other any slug"
        )
      end

      scenario "only renders in menu section the slugs that contains '_cabildo_', '_participacion_' or '_etica_'" do
        visit root_path(locale: :es)

        click_link "Cabildo Abierto"

        within ".menu-sections" do
          expect(page).to have_link "Cabildo related page"
          expect(page).not_to have_link "Participation related page"
          expect(page).not_to have_link "Ethics related page"
          expect(page).not_to have_link "Other any slug"
        end

        click_link "Participación y colaboración"

        within ".menu-sections" do
          expect(page).to have_link "Participation related page"
          expect(page).not_to have_link "Cabildo related page"
          expect(page).not_to have_link "Ethics related page"
          expect(page).not_to have_link "Other any slug"
        end

        click_link "Ética Pública"

        within ".menu-sections" do
          expect(page).to have_link "Ethics related page"
          expect(page).not_to have_link "Cabildo related page"
          expect(page).not_to have_link "Participation related page"
          expect(page).not_to have_link "Other any slug"
        end
      end
    end
  end
end
