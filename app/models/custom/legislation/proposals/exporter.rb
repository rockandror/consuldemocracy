class Legislation::Proposals::Exporter
  require "csv"

  def initialize(process)
    @process = process
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @process.proposals.each { |proposal| csv << csv_values(proposal) }
    end
  end

  private

    def headers
      [
        I18n.t("admin.legislation.proposals.export_list.id"),
        I18n.t("admin.legislation.proposals.export_list.title"),
        I18n.t("admin.legislation.proposals.export_list.description"),
        I18n.t("admin.legislation.proposals.export_list.votes_count"),
        I18n.t("admin.legislation.proposals.export_list.comments_count"),
        I18n.t("admin.legislation.proposals.export_list.author_id"),
        I18n.t("admin.legislation.proposals.export_list.author_date_of_birth"),
        I18n.t("admin.legislation.proposals.export_list.author_location"),
        I18n.t("admin.legislation.proposals.export_list.author_gender"),
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.description,
        proposal.cached_votes_total,
        proposal.comments_count,
        proposal.author.id,
        proposal.author.date_of_birth,
        get_location(proposal.author.location),
        get_gender(proposal.author.gender)
      ]
    end

    def get_gender(gender_key)
      if gender_key
        return I18n.t("activemodel.models.user.gender.#{gender_key}")
      else
        return ""
      end
    end

    def get_location(location_key)
      if location_key
        return I18n.t("activemodel.models.user.locations.values.#{location_key}")
      else
        return ""
      end
    end
end
