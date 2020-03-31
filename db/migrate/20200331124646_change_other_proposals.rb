class ChangeOtherProposals < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_other_proposals, :type, :type_other_proposal
  end
end
