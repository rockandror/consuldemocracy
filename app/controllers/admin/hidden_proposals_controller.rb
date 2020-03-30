class Admin::HiddenProposalsController < Admin::BaseController
  include FeatureFlags

  has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index

  feature_flag :proposals
  feature_flag :legislation_proposals

  before_action :load_proposal, only: [:confirm_hide, :restore]
  before_action :load_resources, only: [:index]

  def index
    @proposals = Proposal.only_hidden.send(:"#{@current_filter}").order(hidden_at: :desc)
    @proposals_legislation = @proposals_legislation.only_hidden.send(:"#{@current_filter}").order(hidden_at: :desc)

    @datos_comunes =  @proposals_legislation + @proposals
    @datos_comunes.compact
    if @current_order.to_s == "created_at"
      @datos_comunes = @datos_comunes.sort_by { |a| a.try(:created_at) }.reverse
    elsif @current_order.to_s == "flags" || @current_order.blank?
      @datos_comunes = @datos_comunes.sort_by { |a| [a.try(:flags_count), a.try(:updated_at)] }.reverse
    end
    @datos_comunes = Kaminari.paginate_array(@datos_comunes).page(params[:page]).per(50)
  end

  def confirm_hide
    if params[:tipo] == 'legislation_proposal'
      @proposals_legislation.confirm_hide
    else
      @proposal.confirm_hide
    end
    redirect_to admin_hidden_proposals_path(params_strong)
  end

  def restore
    if params[:tipo] == 'legislation_proposal'
      @proposals_legislation.restore
      @proposals_legislation.ignore_flag
    else
      @proposal.restore
      @proposal.ignore_flag
    end
    Activity.log(current_user, :restore, @datos_comunes)
    redirect_to admin_hidden_proposals_path(params_strong)
  end

  private

  def params_strong
    params.permit(:filter)
  end

  def load_proposal
    @proposals_legislation = Legislation::Proposal.with_hidden.find(params[:id])
    @proposals = Proposal.with_hidden.find(params[:id])
  end

  def load_resources
    @proposals = Proposal.accessible_by(current_ability, :moderate).where.not(hidden_at: nil)
    @proposals_legislation = Legislation::Proposal.accessible_by(current_ability, :moderate).where.not(hidden_at: nil)
  end

end
