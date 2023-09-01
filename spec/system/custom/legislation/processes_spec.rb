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

context "processes home page" do
  scenario "Participation phases are displayed on current locale" do
    process = create(:legislation_process, proposals_phase_start_date: Date.new(2018, 01, 01),
                                           proposals_phase_end_date: Date.new(2018, 12, 01))

    visit legislation_process_path(process)

    expect(page).to have_content("Participation phases")
    expect(page).to have_content("Proposals")
    expect(page).to have_content("01 Jan 2018 - 01 Dec 2018")

    visit legislation_process_path(process, locale: "es")

    expect(page).to have_content("Participa")
    expect(page).to have_content("Propuestas")
    expect(page).to have_content("01 ene 2018 - 01 dic 2018")
  end
end
end
