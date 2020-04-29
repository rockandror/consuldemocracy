class Legislation::OtherProposal < ApplicationRecord
    belongs_to :proposal, class_name: "Legislation::Proposal"
    has_and_belongs_to_many :categories, -> { order(name: :asc) },  :join_table => :legislation_cat_prop, class_name: "Legislation::Category"
   
    validates :name, presence: true
    
    def resource_model
        Legislation::OtherProposal
    end
end
