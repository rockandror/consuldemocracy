class CreateTableEventAgends < ActiveRecord::Migration[5.0]
  def change
    create_table :event_agends do |t|
      t.date :date_at
      t.string :hour_at
      t.text :content

      t.timestamps null: false
    end
  end
end
