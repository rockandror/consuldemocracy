class AddPermitLikeProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :permit_like_proposals, :boolean, :default => false
  end
end
