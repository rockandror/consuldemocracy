class Moderation::Voting::ProposalsController < Moderation::BaseController
  include FeatureFlags
  PER_PAGE = 50

  has_filters %w[voting_pending all voting_enabled voting_disabled], only: :index

  feature_flag :proposals

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter).page(params[:page]).per(PER_PAGE).order(current_order)
  end

  def review
    @proposals = @proposals.where(id: params[:proposal_ids])
    if params[:disable_voting].present?
      @proposals.each { |proposal| disable_voting(proposal) }
    elsif params[:enable_voting].present?
      @proposals.each { |proposal| enable_voting(proposal) }
    elsif params[:remove_review].present?
      @proposals.each { |proposal| remove_review(proposal) }
    end
    redirect_with_query_params_to({ action: :index },
      { notice: I18n.t("moderation.voting.proposals.update_notice") })
  end

  private

    def current_order
      if %w[voting_enabled voting_disabled].include?(@current_filter)
        { created_at: :desc }
      else
        { created_at: :asc }
      end
    end

    def disable_voting(proposal)
      proposal.update!(voting_enabled: false)
      Activity.log(current_user, :disable_voting, proposal)
    end

    def enable_voting(proposal)
      proposal.update!(voting_enabled: true)
      Activity.log(current_user, :enable_voting, proposal)
    end

    def remove_review(proposal)
      proposal.update!(voting_enabled: nil)
      Activity.log(current_user, :remove_voting_review, proposal)
    end
end
