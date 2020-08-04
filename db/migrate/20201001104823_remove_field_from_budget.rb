class RemoveFieldFromBudget < ActiveRecord::Migration
  def change
    remove_column :budgets, :member_type_id
  end
end
