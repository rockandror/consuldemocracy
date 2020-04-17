class ChangeProposalsOtherProposalType < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_proposals, :other_proposal_type, :type_other_proposal
  end
end
