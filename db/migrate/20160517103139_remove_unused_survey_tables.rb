class RemoveUnusedSurveyTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :survey_answers
    drop_table :open_answers
  end
end
