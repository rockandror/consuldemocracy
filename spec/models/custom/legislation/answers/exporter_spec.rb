require "rails_helper"

describe Legislation::Answers::Exporter do
  let(:answer) { create(:legislation_answer) }

  context "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Answers::Exporter.new(answer.question.process).to_csv

        csv_contents = "ID,Tipo de respuesta,ID de la pregunta,Texto de la pregunta,Respuesta,Usuario\n"\
                       "#{answer.id},Opcional,#{answer.question.id},#{answer.question.title},"\
                       "#{answer.question_option.value},#{answer.user.id}\n"
        expect(csv).to eq csv_contents
      end
    end
  end
end
