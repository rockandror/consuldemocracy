require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController
  before_action :authenticate_user!

  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))
    if @proposal.save
      @proposal.publish
      redirect_to share_proposal_path(@proposal), notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  private

    def proposal_params
      attributes = [:video_url, :responsible_name, :tag_list, :terms_of_service,
                    :geozone_id, :skip_map, :related_sdg_list,
                    image_attributes: image_attributes,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment,
                                           :user_id, :_destroy],
                    map_location_attributes: [:latitude, :longitude, :zoom]]
      translations_attributes = translation_params(Proposal, except: :retired_explanation)
      params.require(:proposal).permit(attributes, translations_attributes)
    end
end
