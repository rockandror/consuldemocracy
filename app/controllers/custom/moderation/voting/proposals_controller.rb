class Moderation::Voting::ProposalsController < Moderation::BaseController
  include FeatureFlags
  PER_PAGE = 50

  has_filters %w[voting_pending all voting_enabled voting_disabled], only: :index

  feature_flag :proposals

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter).page(params[:page]).per(PER_PAGE).order(current_order)
  end

  private

    def current_order
      if %w[voting_enabled voting_disabled].include?(@current_filter)
        { created_at: :desc }
      else
        { created_at: :asc }
      end
    end
end
