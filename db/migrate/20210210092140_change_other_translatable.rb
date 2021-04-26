class ChangeOtherTranslatable < ActiveRecord::Migration[5.0]
  def up
    add_column :sures_actuations, :other, :string
  end

  def down
    remove_column :sures_actuations, :other
  end
end
