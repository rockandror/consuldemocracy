require "rails_helper"

describe "Admin collaborative legislation", :admin do
  context "Index" do
    scenario "Shows a download link per process", :no_js do
      process = create(:legislation_process)

      visit admin_legislation_processes_path(filter: "all", locale: :es)
      within "#legislation_process_#{process.id}" do
        click_link("Descargar CSV")
      end

      header = page.response_headers["Content-Disposition"]
      expect(header).to match(/^attachment;/)
      expect(header).to match(/filename="process_#{process.id}.zip"/)
      expect(page.body).to include "process.csv"
      expect(page.body).to include "questions_answers.csv"
      expect(page.body).to include "draft_comments.csv"
      expect(page.body).to include "proposals.csv"
    end
  end

  context "Update" do
    let!(:process) do
      create(:legislation_process)
    end

    scenario "Allows administrators to enter a list of tags" do
      visit edit_admin_legislation_process_path(process, locale: :es)

      fill_in "Etiquetas", with: "deporte, salud"
      click_button "Guardar cambios"

      expect(page).to have_content "Proceso actualizado correctamente"

      click_link "Haz click para verlo"

      expect(page).to have_content "deporte"
      expect(page).to have_content "salud"
    end
  end
end
