class CreateActivityLogs < ActiveRecord::Migration[5.2]
  def change
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
