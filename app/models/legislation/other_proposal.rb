class Legislation::OtherProposal < ApplicationRecord
    belongs_to :proposal, class_name: "Legislation::Proposal"
    
    def resource_model
        Legislation::OtherProposal
    end
end
