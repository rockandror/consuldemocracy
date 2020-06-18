class RenameColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :legislation_cat_prop, :legislation_category_id, :category_id
    rename_column :legislation_cat_prop, :legislation_other_proposal_id, :other_proposal_id
  end
end
