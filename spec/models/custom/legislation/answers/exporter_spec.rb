require "rails_helper"

describe Legislation::Answers::Exporter do
  let(:user) { create(:user, geozone: create(:geozone), gender: User::GENDER.sample) }
  let(:answer) { create(:legislation_answer, user: user) }
  let!(:comment) { create(:comment, commentable: answer.question, user: user) }

  describe "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Answers::Exporter.new(answer.question.process).to_csv

        user_gender = I18n.t("activemodel.models.user.gender.#{answer.user.gender}")
        comment_user_gender = I18n.t("activemodel.models.user.gender.#{comment.user.gender}")
        csv_contents = "ID,Tipo de respuesta,ID de la pregunta,Texto de la pregunta,Respuesta," \
                       "ID del usuario,Fecha de nacimiento del autor,Localidad del autor,Género del autor\n" \
                       "#{comment.id},Libre,#{answer.question.id},#{answer.question.title}," \
                       "#{comment.body},#{comment.user.id},#{comment.user.date_of_birth}," \
                       "#{comment.user.geozone&.name},#{comment_user_gender}\n" \
                       "#{answer.id},Opcional,#{answer.question.id},#{answer.question.title}," \
                       "#{answer.question_option.value},#{answer.user.id},#{answer.user.date_of_birth}," \
                       "#{answer.user.geozone.name},#{user_gender}\n"
        expect(csv).to eq csv_contents
      end
    end

    scenario "user without optional fields generate csv with answer content" do
      user.update(geozone: nil, gender: nil, date_of_birth: nil)

      I18n.with_locale(:es) do
        csv = Legislation::Answers::Exporter.new(answer.question.process).to_csv

        csv_contents = "ID,Tipo de respuesta,ID de la pregunta,Texto de la pregunta,Respuesta," \
                       "ID del usuario,Fecha de nacimiento del autor,Localidad del autor,Género del autor\n" \
                       "#{comment.id},Libre,#{answer.question.id},#{answer.question.title}," \
                       "#{comment.body},#{comment.user.id},,,\n" \
                       "#{answer.id},Opcional,#{answer.question.id},#{answer.question.title}," \
                       "#{answer.question_option.value},#{answer.user.id},,,\n"

        expect(csv).to eq csv_contents
      end
    end
  end
end
