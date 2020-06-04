class AddOthersLegislationQuestionOptionTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_question_option_translations, :other, :boolean, default: false
    remove_column :legislation_questions, :others_enabled
  end
end
