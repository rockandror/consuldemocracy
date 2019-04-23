class AddIndexToNvotes < ActiveRecord::Migration[4.2]
  def change
    add_index :poll_nvotes, :voter_hash
    add_index :poll_nvotes, :user_id
  end
end
