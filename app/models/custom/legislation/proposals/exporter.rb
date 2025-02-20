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
        I18n.t("admin.legislation.proposals.export_list.author_id"),
        I18n.t("admin.legislation.proposals.export_list.votes_count"),
        I18n.t("admin.legislation.proposals.export_list.comments_count")
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.description,
        proposal.author.id,
        proposal.cached_votes_total,
        proposal.comments_count
      ]
    end
end
