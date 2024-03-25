require "rails_helper"

describe "System Emails", :admin do
  context "Contact system email" do
    scenario "appears in the system email index page and we can access to his view" do
      visit admin_system_emails_path(locale: :es)

      within("#contact") { click_link "Ver" }

      expect(page).to have_content "Asunto de ejemplo"
      expect(page).to have_content "El usuario Juan con dirección de correo " \
                                   "juan@mail.com ha enviado el siguiente mensaje:"
      expect(page).to have_content "Mensaje de ejemplo"
    end
  end
end
