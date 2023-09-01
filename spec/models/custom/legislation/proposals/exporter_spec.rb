require "rails_helper"

describe Legislation::Proposals::Exporter do
  let(:user) { create(:user, geozone: create(:geozone), gender: User::GENDER.sample) }
  let(:proposal) { create(:legislation_proposal, author: user) }

  context "#to_csv" do
    scenario "generate csv with answer content" do
      I18n.with_locale(:es) do
        csv = Legislation::Proposals::Exporter.new(proposal.process).to_csv

        user_gender = I18n.t("activemodel.models.user.gender.#{proposal.author.gender}")
        csv_contents = "ID,Título de la propuesta,Descripción de la propuesta,Votos totales,Número de comentarios,ID del autor,"\
                       "Fecha de nacimiento del autor,Localidad del autor,Género del autor\n"\
                       "#{proposal.id},#{proposal.title},#{proposal.description},#{proposal.cached_votes_total},"\
                       "#{proposal.comments_count},#{proposal.author.id},#{proposal.author.date_of_birth},"\
                       "#{proposal.author.geozone.name},#{user_gender}\n"
        expect(csv).to eq csv_contents
      end
    end

    scenario "user without optional fields generate csv with answer content" do
      user.update(geozone: nil, gender: nil, date_of_birth: nil)

      I18n.with_locale(:es) do
        csv = Legislation::Proposals::Exporter.new(proposal.process).to_csv

        csv_contents = "ID,Título de la propuesta,Descripción de la propuesta,Votos totales,Número de comentarios,ID del autor,"\
                       "Fecha de nacimiento del autor,Localidad del autor,Género del autor\n"\
                       "#{proposal.id},#{proposal.title},#{proposal.description},#{proposal.cached_votes_total},"\
                       "#{proposal.comments_count},#{proposal.author.id},,,\n"

        expect(csv).to eq csv_contents
      end
    end
  end
end
