require "rails_helper"

describe Poll::Exporter do
  let(:user) { create(:user) }
  let!(:poll) { create(:poll) }
  let!(:question_1) { create(:poll_question, :yes_no, poll: poll) }
  let!(:poll_answer) { create(:poll_answer, question: question_1, author: user) }
  let!(:question_2) { create(:poll_question_open, poll: poll) }
  let!(:poll_open_answer) { create(:poll_open_answer, question: question_2, author: user) }
  let(:poll_answers) { Poll::Answer.where(question: poll.questions) }

  describe "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Poll::Exporter.new(poll_answers).to_csv
        poll_answer_content = "#{poll_answer.id},#{poll_answer.question_id},#{poll_answer.answer}," \
                              "#{poll_answer.author_id}"
        poll_open_answer_content = "#{poll_open_answer.id},#{poll_open_answer.question_id}," \
                                   "#{poll_open_answer.answer},#{poll_open_answer.author_id}"

        csv_contents = "ID,ID de la pregunta,Respuesta,ID del autor\n" \
                       "#{poll_answer_content}\n" \
                       "#{poll_open_answer_content}\n"

        expect(csv).to eq csv_contents
      end
    end
  end
end
