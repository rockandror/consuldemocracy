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
      @datos_comunes = @datos_comunes.sort_by { |a| a.flags }
    end
    @datos_comunes = Kaminari.paginate_array(@datos_comunes).page(params[:page]).per(50)

    set_resources_instance
  end


  private

    def resource_model
      Proposal
    end
end
