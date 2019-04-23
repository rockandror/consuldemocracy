class AddProceedingToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :proceeding, :string
    add_index :proposals, :proceeding
  end
end
