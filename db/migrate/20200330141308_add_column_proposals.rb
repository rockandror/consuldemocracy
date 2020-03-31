class AddColumnProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_proposals, :other_proposal_type, :text
    add_reference :legislation_proposals, :legislation_other_proposals, index: true, foreign_key: true
  end
end
