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
      expect(header).to match(/filename="process_#{process.id}.zip"$/)
    end
  end
end
