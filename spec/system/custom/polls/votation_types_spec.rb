require "rails_helper"

describe "Poll Votation Type" do
  let(:author) { create(:user, :level_two) }

  before do
    login_as(author)
  end

  scenario "Open answer" do
    question = create(:poll_question_open)

    visit poll_path(question.poll, locale: :es)

    expect(page).to have_content "Escribe aquí tu respuesta."
    expect(page).to have_content question.title
    expect(page).to have_button "Enviar"
    expect(page).not_to have_button "Enviado"

    within "#poll_question_#{question.id}_answers" do
      fill_in "answer", with: "Some text"
      click_button "Enviar"

      expect(page).to have_content "Some text"
      expect(page).to have_button "Enviado"
      expect(page).not_to have_button "Enviar"

      fill_in "answer", with: "Some another text"

      expect(page).to have_button "Enviar"
      expect(page).not_to have_button "Enviado"
    end
  end
end
