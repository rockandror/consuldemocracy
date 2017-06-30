class Legislation::ProcessesController < Legislation::BaseController
  has_filters %w{open next past}, only: :index
  load_and_authorize_resource :process, class: "Legislation::Process"

  def index
    @current_filter ||= 'open'
    @processes = ::Legislation::Process.send(@current_filter).published.page(params[:page])
  end

  def show
    draft_version = @process.draft_versions.published.last

    if @process.allegations_phase.enabled? && @process.allegations_phase.started? && draft_version.present?
      redirect_to legislation_process_draft_version_path(@process, draft_version)
    elsif @process.debate_phase.enabled?
      redirect_to debate_legislation_process_path(@process)
    else
      redirect_to allegations_legislation_process_path(@process)
    end
  end

  def debate
    @phase = :debate_phase

    if @process.debate_phase.started?
      render :debate
    else
      render :phase_not_open
    end
  end

  def draft_publication
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


end
