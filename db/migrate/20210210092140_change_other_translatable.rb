class ChangeOtherTranslatable < ActiveRecord::Migration[5.0]
  def up
    add_column :sures_actuations, :other, :string
    remove_column :sures_actuation_translations, :other
  end

  def down
    remove_column :sures_actuations, :other
    add_column :sures_actuation_translations, :other, :string
  end
end
