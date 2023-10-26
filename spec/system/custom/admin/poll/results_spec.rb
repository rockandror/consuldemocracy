require "rails_helper"

describe "Admin polls result", :admin do
  let!(:user) { create(:user) }
  let!(:poll) { create(:poll, :expired) }
  let!(:question_1) { create(:poll_question, :yes_no, poll: poll) }
  let!(:poll_answer) { create(:poll_answer, question: question_1, author: user) }
  let!(:question_2) { create(:poll_question_open, poll: poll) }
  let!(:poll_open_answer) { create(:poll_open_answer, question: question_2, author: user) }

  scenario "Download all answers", :no_js do
    poll_answer_content = "#{poll_answer.id},#{poll_answer.question_id},#{poll_answer.answer}," \
                          "#{poll_answer.author_id}"
    poll_open_answer_content = "#{poll_open_answer.id},#{poll_open_answer.question_id}," \
                               "#{poll_open_answer.answer},#{poll_open_answer.author_id}"
    csv_contents = "ID,ID de la pregunta,Respuesta,ID del autor\n" \
                   "#{poll_answer_content}\n" \
                   "#{poll_open_answer_content}\n"

    visit admin_poll_results_path(poll, locale: :es)
    click_link "Descargar selección actual"

    expect(page.response_headers["Content-Type"]).to eq "text/csv"
    expect(page.response_headers["Content-Disposition"]).to match(/answers.csv/)
    expect(page.body).to eq csv_contents
  end
end
