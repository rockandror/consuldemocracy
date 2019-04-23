class AddSlugToBudgetHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :slug, :string
  end
end
