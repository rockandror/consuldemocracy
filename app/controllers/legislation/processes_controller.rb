class Legislation::ProcessesController < Legislation::BaseController
  include RandomSeed

  has_filters %w[open past], only: :index
  has_filters %w[random winners updated proposals_top_relevance], only: :proposals

  load_and_authorize_resource :process

  before_action :set_random_seed, only: :proposals

  def index
    @current_filter ||= "open"
    @processes = ::Legislation::Process.send(@current_filter).includes(:geozones).published
                 .not_in_draft.order(geozone_restricted: :asc,start_date: :desc).page(params[:page])
  end

  def show
    draft_version = @process.draft_versions.published.last
    allegations_phase = @process.allegations_phase

    if @process.homepage_enabled? && @process.homepage.present?
      render :show
    elsif  allegations_phase.enabled? && allegations_phase.started? && draft_version.present?
      redirect_to legislation_process_draft_version_path(@process, draft_version)
    elsif @process.debate_phase.enabled?
      redirect_to debate_legislation_process_path(@process)
    elsif @process.proposals_phase.enabled?
      redirect_to proposals_legislation_process_path(@process)
    else
      redirect_to allegations_legislation_process_path(@process)
    end
  end

  def debate
    set_process
    @phase = :debate_phase

    if @process.debate_phase.started? || (current_user && current_user.administrator?)
      render :debate
    else
      render :phase_not_open
    end
  end

  def draft_publication
    set_process
    @phase = :draft_publication

    if @process.draft_publication.started?
      draft_version = @process.draft_versions.published.last

      if draft_version.present?
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def allegations
    set_process
    @phase = :allegations_phase

    if @process.allegations_phase.started?
      draft_version = @process.draft_versions.published.last

      if draft_version.present?
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def result_publication
    set_process
    @phase = :result_publication

    if @process.result_publication.started?
      final_version = @process.final_draft_version

      if final_version.present?
        redirect_to legislation_process_draft_version_path(@process, final_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def milestones
    @phase = :milestones
  end

  def proposals
    set_process
    @phase = :proposals_phase
    @aditional_filters = []
    @aditional_filters = Legislation::Category.where(legislation_process_id: @process.id)
    params[:type] ||= "other" if @process.permit_hiden_proposals

    if params[:type].blank?
      @proposals = Legislation::Proposal.where(process: @process).where(type_other_proposal: nil)
    else
      
      @proposals = Legislation::Proposal.where(process: @process).where("legislation_proposals.type_other_proposal is not null").with_ignored_flag
    end
    
    @proposals = @proposals.search(params[:search]) if params[:search].present?
    @current_filter = "random" if params[:filter].blank? #&& @proposals.winners.any?
    if params[:map].to_s != "false"
      if !params[:search].blank? && @proposals.count > 0
        if !params[:filter].blank? && @proposals.find_by(type_other_proposal: params[:filter]).blank?
          params[:filter] = @proposals.first.type_other_proposal
        elsif params[:filter].blank?
          params[:filter] = @proposals.first.type_other_proposal
        elsif !params[:filter].blank? && !@proposals.find_by(type_other_proposal: params[:filter]).blank?
          params[:filter]
        end
      end
    end


    params[:filter] = "shops" if params[:filter].blank? && !params[:type].blank?
    
    if params[:type].blank?
      if !params[:filter].blank? 
        @proposals = @proposals.joins(:categories).where("legislation_categories.tag = ?", params[:filter]).page(params[:page])
      elsif @current_filter == "random"
        @proposals = @proposals.sort_by_random(session[:random_seed]).page(params[:page])
      elsif @current_filter == "winners"
        @proposals = @proposals.send(@current_filter).page(params[:page])
      elsif  @current_filter == "proposals_top_relevance"
        @proposals = Kaminari.paginate_array(@proposals.where("cached_votes_up > 0").sort_by {|x| x.likes}.reverse.take(10)).page(params[:page])
      elsif @current_filter == "updated"
        @proposals = @proposals.order(updated_at: :desc).page(params[:page])
      else
        @proposals = @proposals.order('id DESC').page(params[:page])
      end
    else
      if params[:filter] == "carriers"
        @proposals = @proposals.where(type_other_proposal: "carriers").page(params[:page])
      elsif params[:filter] == "shops"
        @proposals = @proposals.where(type_other_proposal: "shops").page(params[:page])
      elsif params[:filter] == "associations"
        @proposals = @proposals.where(type_other_proposal: "associations").page(params[:page])
      else 
        @proposals = @proposals.joins(:categories).where("legislation_categories.tag = ?", params[:filter]).page(params[:page])
      end
    end 
    
    if @process.proposals_phase.started? || (current_user && current_user.administrator?)
      legislation_proposal_votes(@proposals)
      render :proposals
    else
      render :phase_not_open
    end
  end

  private

    def member_method?
      params[:id].present?
    end

    def set_process
      return if member_method?
      @process = ::Legislation::Process.find(params[:process_id])
    end
end
