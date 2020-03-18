class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w{no_flags_proposals pending_flag_review with_ignored_flag with_confirmed_hide_at}, only: :index
  has_orders %w{flags created_at}, only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    super
    @proposal_legislation = Legislation::Proposal. accessible_by(current_ability, :moderate).send(:"#{@current_filter}")
            .send("sort_by_#{@current_order}")
            .page(params[:page])
            .per(50)
  end
  private

    def resource_model
      Proposal
    end
end
