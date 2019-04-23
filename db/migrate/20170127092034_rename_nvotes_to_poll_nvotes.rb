class RenameNvotesToPollNvotes < ActiveRecord::Migration[4.2]
  def change
    rename_table :nvotes, :poll_nvotes
  end
end
