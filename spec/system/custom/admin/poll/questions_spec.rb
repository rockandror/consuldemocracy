require "rails_helper"

describe "Admin poll questions", :admin do
  describe "Create" do
    describe "With :open votation type" do
      scenario "display open text, fields and redirect to admin poll path" do
        poll = create(:poll, :future)
        visit admin_poll_path(poll, locale: :es)
        click_link "Crear pregunta ciudadana"

        expect(page).not_to have_content "Permite que el usuario responda libremente en un cuadro de texto."

        fill_in "Pregunta", with: "Pregunta con respuesta abierta"
        select "Respuesta abierta", from: "Tipo de votación"

        expect(page).to have_content "Permite que el usuario responda libremente en un cuadro de texto."
        expect(page).not_to have_content "Número máximo de votos"

        click_button "Guardar"

        expect(page).to have_content "Pregunta con respuesta abierta"
        expect(page).to have_current_path(admin_poll_path(poll))
      end
    end
  end

  scenario "Update open question" do
    poll = create(:poll, :future)
    question = create(:poll_question_open, poll: poll)
    old_title = question.title
    new_title = "Nuevo título de pregunta abierta"

    visit admin_poll_path(poll, locale: :es)

    within("tr", text: old_title) { click_link "Editar" }

    expect(page).to have_link "Volver", href: admin_poll_path(poll)
    fill_in "Pregunta", with: new_title

    click_button "Guardar"

    expect(page).to have_content "Cambios guardados"
    expect(page).to have_content new_title
    expect(page).not_to have_content old_title
    expect(page).to have_current_path(admin_poll_path(poll))
  end
end
