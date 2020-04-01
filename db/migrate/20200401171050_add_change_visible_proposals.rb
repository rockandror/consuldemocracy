class AddChangeVisibleProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :permit_hiden_proposals, :boolean
  end
end
