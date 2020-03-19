class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w{no_flags_proposals pending_flag_review with_ignored_flag with_confirmed_hide_at}, only: :index
  has_orders %w{flags created_at}, only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(:"#{@current_filter}")
    @proposals_legislation = @proposals_legislation.send(:"#{@current_filter}")

    @datos_comunes =  @proposals_legislation + @proposals
    @datos_comunes.compact
    if @current_order.to_s == "created_at"
      @datos_comunes = @datos_comunes.sort_by { |a| a.try(:created_at) }.reverse
    elsif @current_order.to_s == "flags" || @current_order.blank?
      @datos_comunes = @datos_comunes.sort_by { |a| [a.try(:flags_count), a.try(:updated_at)] }.reverse
    end
    @datos_comunes = Kaminari.paginate_array(@datos_comunes).page(params[:page]).per(50)

    set_resources_instance
  end

  def moderate
    set_resource_params
    @proposals_legislation = @proposals_legislation.where("id IN (?)", params[:legislation_proposal_ids])
    @proposals = @proposals.where("id IN (?)", params[:new_proposal_ids])

    if params[:hide_proposals].present?
      @proposals_legislation.accessible_by(current_ability, :hide).each {|proposal_legislation| hide_resource proposal_legislation}
      @proposals.accessible_by(current_ability, :hide).each {|proposal| hide_resource proposal}

    elsif params[:ignore_flags].present?
      @proposals_legislation.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
      @proposals.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)
    elsif params[:block_authors].present?
      author_ids = @proposals_legislation.pluck(author_id).uniq
      author_ids = author_id + @proposals.pluck(author_id).uniq
      author_id = author_id.uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    redirect_to request.query_parameters.merge(action: :index).merge(params_strong)
  end


  private

  def resource_model
    Proposal
  end

  def load_resources
    @proposals = Proposal.accessible_by(current_ability, :moderate).where.not(published_at: nil)
    @proposals_legislation = Legislation::Proposal.accessible_by(current_ability, :moderate)
  end


  def set_resource_params
   
    params[:proposal_ids].each do |p|
      if p.include?('legislation_proposal')
        params[:legislation_proposal_ids] ||= []
        params[:legislation_proposal_ids].push(p.gsub("_legislation_proposal",""))
      else
        params[:new_proposal_ids] ||= []
        params[:new_proposal_ids].push(p.gsub("_proposal",""))
      end
    end
  end
end
