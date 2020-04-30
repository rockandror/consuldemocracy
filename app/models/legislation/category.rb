class Legislation::Category < ApplicationRecord
    belongs_to :process, class_name: "Legislation::Process", foreign_key: "legislation_process_id"
    has_and_belongs_to_many :other_proposals, -> { order(:id) }, class_name: "Legislation::OtherProposal", :join_table => :legislation_cat_prop, dependent: :destroy

    validates :name, presence: true
end