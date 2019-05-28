class DropBudgetRecommendations < ActiveRecord::Migration[5.0]
  def change
    drop_table :budget_recommendations
  end
end
