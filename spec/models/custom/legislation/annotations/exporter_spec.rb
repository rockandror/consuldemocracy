require "rails_helper"

describe Legislation::Annotations::Exporter do
  let(:user) { create(:user, geozone: create(:geozone), gender: User::GENDER.sample) }
  let(:annotation) { create(:legislation_annotation, author: user) }

  context "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Annotations::Exporter.new(annotation.draft_version.process).to_csv

        comment = annotation.comments.first
        version = annotation.draft_version
        user_gender = I18n.t("activemodel.models.user.gender.#{comment.user.gender}")
        csv_contents = "ID,Comentario,ID del borrador,Versión del borrador,ID de la anotación,Texto de la anotación,"\
                       "ID del usuario,Fecha de nacimiento del autor,Localidad del autor,Género del autor\n"\
                       "#{comment.id},#{comment.body},#{version.id},#{version.title},#{annotation.id},"\
                       "#{annotation.quote},#{comment.user.id},#{comment.user.date_of_birth},"\
                       "#{comment.user.geozone.name},#{user_gender}\n"
        expect(csv).to eq csv_contents
      end
    end

    scenario "user without optional fields generate csv with answer content" do
      user.update(geozone: nil, gender: nil, date_of_birth: nil)

      I18n.with_locale(:es) do
        csv = Legislation::Annotations::Exporter.new(annotation.draft_version.process).to_csv

        comment = annotation.comments.first
        version = annotation.draft_version
        csv_contents = "ID,Comentario,ID del borrador,Versión del borrador,ID de la anotación,Texto de la anotación,"\
                       "ID del usuario,Fecha de nacimiento del autor,Localidad del autor,Género del autor\n"\
                       "#{comment.id},#{comment.body},#{version.id},#{version.title},#{annotation.id},"\
                       "#{annotation.quote},#{comment.user.id},,,\n"

        expect(csv).to eq csv_contents
      end
    end
  end
end
