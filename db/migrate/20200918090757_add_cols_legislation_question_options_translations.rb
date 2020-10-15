class AddColsLegislationQuestionOptionsTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_question_option_translations, :is_range, :boolean
    add_column :legislation_question_option_translations, :range_first, :integer, default: 1
    add_column :legislation_question_option_translations, :range_last, :integer, default: 2
    add_column :legislation_question_option_translations, :is_number, :boolean
  end
end
