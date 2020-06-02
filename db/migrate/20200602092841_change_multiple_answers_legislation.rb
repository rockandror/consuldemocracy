class ChangeMultipleAnswersLegislation < ActiveRecord::Migration[5.0]
  def change
    change_column :legislation_questions, :multiple_answers, :integer, :default => 1
  end
end
