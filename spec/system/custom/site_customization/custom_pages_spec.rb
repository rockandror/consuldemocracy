require "rails_helper"

describe "Custom Pages" do
  scenario "Related custom pages to main links section can be accessed" do
    visit root_path(locale: :es)

    click_link "Cabildo Abierto"

    expect(page).to have_css "h1", text: "¿Qué es cabildoabierto.tenerife.es?"

    click_link "Participación y colaboración"

    expect(page).to have_css "h1", text: "Conoce lo que hacemos"

    click_link "Ética Pública"

    expect(page).to have_css "h1", text: "Código de Buen Gobierno"
  end

  describe "Menu" do
    context "Custom pages related to main links" do
      scenario "always render menu but news link only present in cabildo custom page" do
        visit root_path(locale: :es)
        click_link "Cabildo Abierto"

        within ".menu-title" do
          expect(page).to have_content "Cabildo Abierto"
        end

        within ".menu-sections" do
          expect(page).to have_link "¿Qué es cabildoabierto.tenerife.es?"
          expect(page).to have_link "Noticias"
        end

        click_link "Participación y colaboración"

        within ".menu-title" do
          expect(page).to have_content "Participación y Colaboración Ciudadana"
        end

        within ".menu-sections" do
          expect(page).to have_link "Conoce lo que hacemos"
          expect(page).not_to have_link "Noticias"
        end

        click_link "Ética Pública"

        within ".menu-title" do
          expect(page).to have_content "Ética Pública"
        end

        within ".menu-sections" do
          expect(page).to have_link "Código de Buen Gobierno"
          expect(page).not_to have_link "Noticias"
        end
      end
    end

    context "Other custom pages" do
      scenario "only renders the menu section when the slugs contain '_cabildo_', " \
               "'_participacion_' or '_etica_'" do
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
               title: "Cabildo related page")
        create(:site_customization_page, :published,
               slug: "_participacion_any-slug",
               title: "Participation related page")
        create(:site_customization_page, :published,
               slug: "_etica_any-slug",
               title: "Ethics related page")
        create(:site_customization_page, :published,
               slug: "_other_any-slug",
               title: "Other any slug")
      end

      scenario "only renders in menu section the slugs that contains '_cabildo_', " \
               "'_participacion_' or '_etica_'" do
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

  describe "News" do
    scenario "render news pages" do
      create(:site_customization_page, :published, :news, slug: "any-news", title: "Sample news")

      visit root_path(locale: :es)

      click_link "Cabildo Abierto"
      click_link "Noticias"

      expect(page).to have_content "Sample news"
      expect(page).to have_css "[href='any-news']"
    end
  end

  describe "Breadcrumbs" do
    context "Main links sections" do
      scenario "render in Cabildo custom page" do
        visit root_path(locale: :es)

        click_link "Cabildo Abierto"

        expect(page).to have_content "Inicio > Cabildo Abierto > ¿Qué es cabildoabierto.tenerife.es?"
        expect(page).to have_link "Inicio", href: root_path
        expect(page).to have_link "Cabildo Abierto", href: "#"
        expect(page).to have_link "¿Qué es cabildoabierto.tenerife.es?",
                                  href: "_cabildo_que-es-el-cabildo-abierto"
      end

      scenario "Participation" do
        visit root_path(locale: :es)

        click_link "Participación y colaboración"

        expect(page).to have_content "Inicio > Participación y colaboración ciudadana > Conoce lo que hacemos"
        expect(page).to have_link "Inicio", href: root_path
        expect(page).to have_link "Participación y colaboración ciudadana", href: "#"
        expect(page).to have_link "Conoce lo que hacemos", href: "_participacion_que-hacemos"
      end

      scenario "Ethics" do
        visit root_path(locale: :es)

        click_link "Ética Pública"

        expect(page).to have_content "Inicio > Ética Pública > Código de Buen Gobierno"
        expect(page).to have_link "Inicio", href: root_path
        expect(page).to have_link "Ética Pública", href: "#"
        expect(page).to have_link "Código de Buen Gobierno",
                                  href: "_etica_codigo-de-buen-gobierno-y-seguimiento"
      end
    end

    context "News" do
      scenario "News link" do
        visit root_path(locale: :es)

        click_link "Cabildo Abierto"
        click_link "Noticias"

        expect(page).to have_content "Inicio > Cabildo Abierto > Noticias"
        expect(page).to have_link "Inicio", href: root_path
        expect(page).to have_link "Cabildo Abierto", href: "#"
        expect(page).to have_link "Noticias", href: "#"
      end

      scenario "News page" do
        create(:site_customization_page, :published, :news, slug: "any-news", title: "Sample news")

        visit "any-news?locale=es"

        expect(page).to have_content "Inicio > Cabildo Abierto > Noticias > Sample news"
        expect(page).to have_link "Inicio", href: root_path
        expect(page).to have_link "Cabildo Abierto", href: "#"
        expect(page).to have_link "Noticias", href: news_path
        expect(page).to have_link "Sample news", href: "any-news"
      end
    end

    scenario "Custom pages" do
      create(:site_customization_page, :published, slug: "new-slug", title: "Custom title")

      visit "new-slug?locale=es"

      expect(page).to have_content "Inicio > Custom title"
      expect(page).to have_link "Inicio", href: root_path
      expect(page).to have_link "Custom title", href: "new-slug"
    end
  end
end
