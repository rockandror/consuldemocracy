class CreateBudgetInvestmentInterests < ActiveRecord::Migration
  def change
    create_table :budget_investment_interests do |t|
      t.belongs_to :user
      t.integer :investment_id, index: true

      t.timestamps null: false
    end
  end
end
