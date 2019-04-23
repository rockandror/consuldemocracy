class AddPhaseToBudgetRecommendations < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_recommendations, :phase, :string, default: 'selecting'
  end
end
