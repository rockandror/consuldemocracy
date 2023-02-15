require "rails_helper"

describe "Collaborative legislation" do
  let!(:process) do
    create(:legislation_process, title: "Más instalaciones deportivas públicas",
                                 tag_list: "deporte")
  end

  before { login_as(create(:user)) }

  context "Index" do
    scenario "Filters by tag" do
      process = create(:legislation_process, title: "Nuevos centros de urgencias", tag_list: "salud")
      visit legislation_processes_path(locale: :es)

      expect(page).to have_link "deporte", href: legislation_processes_path(search: "deporte")
      expect(page).to have_link "salud", href: legislation_processes_path(search: "salud")

      within "#legislation_process_#{process.id}" do
        click_link "salud"
      end

      expect(page).not_to have_content "Más instalaciones deportivas públicas"
      expect(page).to have_content "Nuevos centros de urgencias"

      click_link "Eliminar filtro por etiqueta"

      expect(page).to have_content "Nuevos centros de urgencias"
      expect(page).to have_content "Más instalaciones deportivas públicas"
    end
  end

  context "Show" do
    scenario "Shows process tags" do
      visit legislation_process_path(process, locale: :es)

      expect(page).to have_link "deporte", href: legislation_processes_path(search: "deporte")
    end
  end
end
