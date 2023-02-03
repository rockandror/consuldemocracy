require_dependency Rails.root.join("app", "controllers", "admin", "proposals_controller").to_s

class Admin::ProposalsController
  def index
    super

    respond_to do |format|
      format.csv do
        unpaged_proposals = @proposals.except(:limit, :offset)
        send_data Proposal::Exporter.new(unpaged_proposals).to_csv,
                  filename: "proposals.csv"
      end
      format.html
    end
  end
end
