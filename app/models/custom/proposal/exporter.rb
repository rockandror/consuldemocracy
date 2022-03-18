class Proposal::Exporter
  require "csv"

  def initialize(proposals)
    @proposals = proposals
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @proposals.each { |proposal| csv << csv_values(proposal) }
    end
  end

  private

    def headers
      [
        I18n.t("admin.proposals.index.export_list.id"),
        I18n.t("admin.proposals.index.export_list.title"),
        I18n.t("admin.proposals.index.export_list.author"),
        I18n.t("admin.proposals.index.export_list.date"),
        I18n.t("admin.proposals.index.export_list.comments"),
        I18n.t("admin.proposals.index.export_list.votes"),
        I18n.t("admin.proposals.index.export_list.summary"),
        I18n.t("admin.proposals.index.export_list.description"),
        I18n.t("admin.proposals.index.export_list.url"),
        I18n.t("admin.proposals.index.export_list.geozone"),
        I18n.t("admin.proposals.index.export_list.tags"),
        I18n.t("admin.proposals.index.export_list.ods")
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.author.username.to_s,
        proposal.published_at,
        proposal.comments.count,
        proposal.total_votes,
        proposal.summary,
        ActionView::Base.full_sanitizer.sanitize(proposal.description),
        proposal.url,
        proposal.geozone.try(:name) || '',
        proposal.tag_list.to_s,
        proposal.sdg_goals.to_a.map { |sdg| sdg.code }
      ]
    end

    def admin(investment)
      if investment.administrator.present?
        investment.administrator.name
      else
        I18n.t("admin.budget_investments.index.no_admin_assigned")
      end
    end

    def price(investment)
      price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
      if investment.feasible?
        "#{I18n.t(price_string)} (#{investment.formatted_price})"
      else
        I18n.t(price_string)
      end
    end
end
