class AddValueOtherLegislationAnswers < ActiveRecord::Migration[5.0]
  def change
    remove_column :legislation_answers, :value_other
    add_column :legislation_answers, :value_other, :string
  end
end
