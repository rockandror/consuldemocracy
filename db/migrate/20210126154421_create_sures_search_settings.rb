class CreateSuresSearchSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :sures_search_settings do |t|
      t.string :title
      t.string :data_type
      t.string :data
      t.string :resource
      t.string :field
      t.string :rules

      t.timestamps
    end
  end
end
