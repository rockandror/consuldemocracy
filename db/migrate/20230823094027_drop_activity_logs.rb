class DropActivityLogs < ActiveRecord::Migration[6.0]
  def up
    drop_table :activity_logs
  end

  def down
    create_table :activity_logs do |t|
      t.string :activity
      t.string :result
      t.string :model
      t.integer :model_id
      t.text :payload

      t.timestamps
    end
  end
end
