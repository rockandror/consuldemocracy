class AddJoinTableCategoriesProposals < ActiveRecord::Migration[5.0]
  def change
    create_table :legislation_cat_prop do |t|
      t.references :legislation_category, foreign_key: true
      t.references :legislation_other_proposal, foreign_key: true
    end
  end
end
