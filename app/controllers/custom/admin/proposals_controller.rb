class Admin::ProposalsController < Admin::BaseController
  include HasOrders
  include CommentableActions
  include FeatureFlags
  include ProposalsHelper
  feature_flag :proposals

  has_orders %w[created_at]

  before_action :load_proposal, except: [:index, :download]

  def show
  end

  def update
    if @proposal.update(proposal_params)
      redirect_to admin_proposal_path(@proposal), notice: t("admin.proposals.update.notice")
    else
      render :show
    end
  end

  def toggle_selection
    @proposal.toggle :selected
    @proposal.save!
  end

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


  private

    def resource_model
      Proposal
    end

    def load_proposal
      @proposal = Proposal.find(params[:id])
    end

    def proposal_params
      params.require(:proposal).permit(:selected)
    end
end
