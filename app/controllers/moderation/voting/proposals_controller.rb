class Moderation::Voting::ProposalsController < Moderation::BaseController
  include FeatureFlags
  extend ActiveSupport::Concern
  include Polymorphic
  PER_PAGE = 50

  feature_flag :proposals

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter).page(params[:page]).per(PER_PAGE)
  end

  def review
    @proposals = @proposals.where(id: params[:proposal_ids])
    redirect_with_query_params_to(action: :index)
  end
end
