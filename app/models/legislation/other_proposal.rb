class Legislation::OtherProposal < ApplicationRecord
    belongs_to :proposals
    
    def resource_model
        Legislation::OtherProposal
    end
end
