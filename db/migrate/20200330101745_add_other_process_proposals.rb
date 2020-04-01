class AddOtherProcessProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :other_proposals_enabled, :boolean
  end
end
