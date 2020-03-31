class ChangeName < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_proposals, :legislation_other_proposals_id, :legislation_other_proposal_id
  end
end
