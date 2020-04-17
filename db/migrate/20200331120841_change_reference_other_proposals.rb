class ChangeReferenceOtherProposals < ActiveRecord::Migration[5.0]
  def change
    remove_reference :legislation_other_proposals, :proposals
    remove_reference :legislation_proposals, :legislation_other_proposal
    add_reference :legislation_proposals, :legislation_other_proposal, index: true, foreign_key: true
  end
end
