class AddSlugToBudgets < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :slug, :string
  end
end
