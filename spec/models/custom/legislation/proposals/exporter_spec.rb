require "rails_helper"

describe Legislation::Proposals::Exporter do
  let(:proposal) { create(:legislation_proposal) }

  context "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Proposals::Exporter.new(proposal.process).to_csv

        csv_contents = "ID,Título de la propuesta,Descripción de la propuesta,ID del autor,Votos totales,Número de comentarios\n"\
                       "#{proposal.id},#{proposal.title},#{proposal.description},#{proposal.author.id},"\
                       "#{proposal.cached_votes_total},#{proposal.comments_count}\n"
        expect(csv).to eq csv_contents
      end
    end
  end
end
