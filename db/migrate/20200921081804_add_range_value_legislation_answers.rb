class AddRangeValueLegislationAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_answers, :value_range, :integer
  end
end
