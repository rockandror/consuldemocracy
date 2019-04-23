class AddDelegatedToVotes < ActiveRecord::Migration[4.2]
  def change
    add_column :votes, :delegated, :boolean, default: false
  end
end
