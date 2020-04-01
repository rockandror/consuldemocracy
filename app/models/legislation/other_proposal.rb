class Legislation::OtherProposal < ApplicationRecord
    belongs_to :proposal, class_name: "Legislation::Proposal"
   
    validates :name, presence: true
    validates :phone, presence: true
    
    def resource_model
        Legislation::OtherProposal
    end
end
