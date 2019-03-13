class AddDelegatedToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :delegated, :boolean, default: false
  end
end
