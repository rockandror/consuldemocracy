class RenameReferencesJoinTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_cat_prop, :legislation_proposal_id, :proposal_id
  end
end
