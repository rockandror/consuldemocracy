class AddProposalTypeToLegislationProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_proposals, :proposal_type, :string
  end
end
