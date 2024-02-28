require "rails_helper"

describe "Admin custom pages", :admin do
  context "Index" do
    scenario "should contain all default custom pages published populated by db:seeds" do
      slugs = %w[_cabildo_que-es-el-cabildo-abierto _etica_codigo-de-buen-gobierno-y-seguimiento
                 _participacion_que-hacemos accessibility census_terms conditions faq privacy
                 welcome_not_verified welcome_level_two_verified welcome_level_three_verified]

      expect(SiteCustomization::Page.count).to be 11
      slugs.each do |slug|
        expect(SiteCustomization::Page.find_by(slug: slug).status).to eq "published"
      end

      visit admin_site_customization_pages_path

      expect(all("[id^='site_customization_page_']").count).to be 11
      slugs.each do |slug|
        expect(page).to have_content slug
      end
    end

    context "Search" do
      before do
        I18n.with_locale(:es) do
          create(:site_customization_page, title: "New title", slug: "example-slug")
          create(:site_customization_page, title: "Old title", slug: "another-example-page-slug")
        end
      end

      scenario "by title" do
        visit admin_site_customization_pages_path(locale: :es)

        fill_in "search-pages", with: "New"

        click_button "Buscar"

        within "#search-pages-results" do
          expect(page).to have_content "Resultados de la búsqueda"
          expect(page).to have_content "New title"
          expect(page).not_to have_content "Old title"
        end

        click_link "Limpiar búsqueda"

        expect(page).not_to have_css "#search-pages-results"

        fill_in "Buscar páginas por título o slug", with: "title"

        click_button "Buscar"

        within "#search-pages-results" do
          expect(page).to have_content "New title"
          expect(page).to have_content "Old title"
        end
      end

      scenario "by slug" do
        visit admin_site_customization_pages_path(locale: :es)

        fill_in "search-pages", with: "another"

        click_button "Buscar"

        within "#search-pages-results" do
          expect(page).to have_content "another-example-page-slug"
          expect(page).not_to have_content "example-slug"
        end
      end

      scenario "by type" do
        I18n.with_locale(:es) do
          create(:site_customization_page, :news, title: "Other title")
        end

        visit admin_site_customization_pages_path(locale: :es)

        choose "Noticias"

        click_button "Buscar"

        within "#search-pages-results" do
          expect(page).to have_content "Other title"
          expect(page).not_to have_content "New title"
          expect(page).not_to have_content "Old title"
        end
      end

      scenario "by dates" do
        I18n.with_locale(:es) do
          create(:site_customization_page, :news, title: "Other title", slug: "other-title")
          create(:site_customization_page, :news,
                 title: "Another title",
                 slug: "another-title",
                 news_date: 1.week.ago,
                 created_at: 1.week.ago)
        end

        visit admin_site_customization_pages_path(locale: :es)

        choose "Noticias"

        fill_in "Desde", with: 2.days.ago
        fill_in "Hasta", with: 2.days.from_now

        click_button "Buscar"

        within "#search-pages-results" do
          expect(page).to have_content "Other title"
          expect(page).not_to have_content "Another title"
        end
      end

      scenario "without results" do
        visit admin_site_customization_pages_path(locale: :es)

        fill_in "search-pages", with: "results"

        click_button "Buscar"

        expect(page).not_to have_css "#search-pages-results"
        expect(page).to have_content "No se han encontrado resultados."
      end
    end
  end

  context "Create" do
    describe "News" do
      scenario "Valid custom page" do
        visit new_admin_site_customization_page_path(locale: :es)

        fill_in "Título", with: "News example"
        fill_in "Slug", with: "news-example-page"
        check "Es noticia"
        fill_in "Fecha de la noticia", with: Date.current

        click_button "Crear Página"

        expect(page).to have_content "News example"
        expect(page).to have_content "news-example-page"
        expect(page).to have_content "Página creada correctamente"
      end
    end
  end
end
