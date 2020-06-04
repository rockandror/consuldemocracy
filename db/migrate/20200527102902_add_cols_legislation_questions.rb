class AddColsLegislationQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_questions, :others_enabled, :boolean, default: false
    add_column :legislation_questions, :multiple_answers, :integer, default: 0
  end
end
