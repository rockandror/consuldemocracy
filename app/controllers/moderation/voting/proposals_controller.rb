class Moderation::Voting::ProposalsController < Moderation::BaseController
  include FeatureFlags
  extend ActiveSupport::Concern
  include Polymorphic
  PER_PAGE = 50

  has_filters %w[pending_voting_review all with_voting_reviewed], only: :index

  feature_flag :proposals

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter).page(params[:page]).per(PER_PAGE)
  end

  def review
    @proposals = @proposals.where(id: params[:proposal_ids])
    if params[:avoid_voting_proposals].present?
      @proposals.each { |proposal| disable_voting(proposal) }
    elsif params[:allow_voting_proposals].present?
      @proposals.each { |proposal| enable_voting(proposal) }
    end
    redirect_with_query_params_to(action: :index)
  end

  private

    def disable_voting(proposal)
      proposal.update!(enabled_voting: false)
      Activity.log(current_user, :avoid_voting, proposal)
    end

    def enable_voting(proposal)
      proposal.update!(enabled_voting: true)
      Activity.log(current_user, :allow_voting, proposal)
    end
end
