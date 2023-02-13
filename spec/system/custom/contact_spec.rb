require "rails_helper"

describe "Contact form" do
  before { allow(Rails.application.secrets).to receive(:contact_email).and_return("any_email@example.prg") }

  scenario "Sends email to cabildo and redirects to home page when form is fullfilled correctly" do
    visit contact_path(locale: "es")

    fill_in "Nombre *", with: "Fulanito"
    fill_in "Email *", with: "fulanito@example.org"
    fill_in "Asunto *", with: "Petición de soporte"
    fill_in "Mensaje *", with: "Necesito ayuda ..."
    check "Acepto la Política de Privacidad"
    click_on "Enviar"

    expect(page).to have_content "Mensaje enviado correctamente"
    expect(page).to have_current_path(root_path)
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

  scenario "Create with invisible_captcha honeypot field", :no_js do
    visit contact_path(locale: "es")

    fill_in "Nombre *", with: "Fulanito"
    fill_in "Email *", with: "fulanito@example.org"
    fill_in "Asunto *", with: "Petición de soporte"
    fill_in "Mensaje *", with: "Necesito ayuda ..."
    check "Acepto la Política de Privacidad"
    fill_in "Si eres humano, por favor ignora este campo", with: "This is a honeypot field"
    click_on "Enviar"

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(contact_path)
  end

  scenario "Do not send the email when user does not accept the privacy policy" do
    visit contact_path(locale: "es")

    fill_in "Nombre *", with: "Fulanito"
    fill_in "Email *", with: "fulanito@example.org"
    fill_in "Asunto *", with: "Petición de soporte"
    fill_in "Mensaje *", with: "Necesito ayuda ..."
    click_on "Enviar"

    expect(page).to have_content("debe ser aceptado")
    expect(page).not_to have_content "Mensaje enviado correctamente"
  end
end
