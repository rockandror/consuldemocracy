class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w{no_flags_proposals pending_flag_review with_ignored_flag with_confirmed_hide_at}, only: :index
  has_orders %w{flags created_at}, only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @proposals = Proposal.accessible_by(current_ability, :moderate)
      .send(:"#{@current_filter}")
      .send("sort_by_#{@current_order}")

    @proposals_legislation = Legislation::Proposal.accessible_by(current_ability, :moderate)
      .send(:"#{@current_filter}")
      .send("sort_by_#{@current_order}")

    @datos_comunes =  @proposals_legislation + @proposals

    if @current_order.to_s == "created_at"
      @datos_comunes = @datos_comunes.sort_by { |a| a.created_at }
    elsif @current_order.to_s == "flags"
      @datos_comunes = @datos_comunes.sort_by { |a| a.flags_count }
    end
    @datos_comunes = Kaminari.paginate_array(@datos_comunes).page(params[:page]).per(50)

    set_resources_instance
  end

  def moderate
    set_resource_params
    @proposals_legislation = @proposals_legislation.where(id: params[:legislation_proposal_ids])
    @proposals = @proposals.where(id: params[:new_proposal_ids])

    if params[:hide_legislation_proposal].present?
      @proposals_legislation.accessible_by(current_ability, :hide).each {|proposal_legislation| hide_resource proposal_legislation}

    elsif params[:ignore_flags].present?
      @proposals_legislation.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
      
    elsif params[:block_authors].present?
      author_ids = @proposals_legislation.pluck(author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    if params[:hide_proposal].present?
      @proposals.accessible_by(current_ability, :hide).each {|proposal| hide_resource proposal}

    elsif params[:ignore_flags].present?
      @proposalsn.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
      
    elsif params[:block_authors].present?
      author_ids = @proposals.pluck(author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    redirect_to request.query_parameters.merge(action: :index).merge(params_strong)
  end


  private

  def resource_model
    Proposal
  end

  # def load_resources
  #   @proposals_legislation = Legistlation::Proposal.accessible_by(current_ability, :moderate)
  #   @proposals = Proposal.accessible_by(current_ability, :moderate)
  # end

  def set_resource_params
    params[:proposal_ids].each do |p|
      if p.include?('Legislation::Proposal')
        zzz
        params[:legislation_proposal_ids] ||= []
        params[:legislation_proposal_ids].push(p.gsub('Legislation::Proposal', 'legislation_proposal').gsub("_legislation_proposal",""))
        params[:hide_legislation_proposal] = params["hide_legislation_proposal"]
      else
        params[:new_proposal_ids] ||= []
        params[:new_proposal_ids].push(p.gsub('Proposal', 'proposal').gsub("_proposal",""))
        params[:hide_proposal] = params["hide_proposals"]
      end
    end
  end
end
