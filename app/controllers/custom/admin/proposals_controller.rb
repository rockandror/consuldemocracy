require_dependency Rails.root.join("app", "controllers", "admin", "proposals_controller").to_s

class Admin::ProposalsController
  include ProposalsHelper

  before_action :load_proposal, except: [:index, :download]

  def download
    @proposals = Proposal.all
    respond_to do |format|
      format.html
      format.js
      format.csv do
        send_data Proposal::Exporter.new(@proposals).to_csv,
                  filename: "proposals.csv"
      end
    end
  end
end
