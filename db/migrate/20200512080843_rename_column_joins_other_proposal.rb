class RenameColumnJoinsOtherProposal < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_cat_prop, :other_proposal_id, :proposal_id
  end
end
