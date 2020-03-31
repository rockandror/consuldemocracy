class OtherProposalsController < ApplicationController
    include CommentableActions
    include FlagActions
    include ImageAttributes
    
    private
    
        def proposal_params
        params.require(:legislation_other_proposal).permit(:type, :name, :address, :phone,
                        :agent, :agent_title,  :citizen_entities, :cif,
                        :entity_type)
        end     
      
      
end
