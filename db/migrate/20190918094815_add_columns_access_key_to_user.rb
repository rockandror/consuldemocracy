class AddColumnsAccessKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :access_key_generated, :text
    add_column :users, :access_key_inserted, :text
    add_column :users, :access_key_generated_at, :date
    add_column :users, :access_key_tried, :integer, default: 0
  end
end
