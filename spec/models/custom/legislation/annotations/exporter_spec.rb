require "rails_helper"

describe Legislation::Annotations::Exporter do
  let(:annotation) { create(:legislation_annotation) }

  context "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Annotations::Exporter.new(annotation.draft_version.process).to_csv

        comment = annotation.comments.first
        version = annotation.draft_version
        csv_contents = "ID,Comentario,Usuario,ID del borrador,Versión del borrador,ID de la anotación,Texto de la anotación\n"\
                       "#{comment.id},#{comment.body},#{comment.user.id},#{version.id},#{version.title},"\
                       "#{annotation.id},#{annotation.quote}\n"
        expect(csv).to eq csv_contents
      end
    end
  end
end
