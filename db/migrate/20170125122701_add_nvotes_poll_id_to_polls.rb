class AddNvotesPollIdToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :nvotes_poll_id, :string
  end
end
