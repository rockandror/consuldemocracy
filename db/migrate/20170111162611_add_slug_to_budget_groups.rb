class AddSlugToBudgetGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_groups, :slug, :string
  end
end
