class OtherProposalsController < ApplicationController
    before_action :authenticate_user!

    load_and_authorize_resource
    def other_proposal_params
        params.require(:legislation_other_proposal).permit(:type, :name, :address, :phone, :agent, :agent_title, :citizen_entities, :cif, :entity_type)
    end
      
end
