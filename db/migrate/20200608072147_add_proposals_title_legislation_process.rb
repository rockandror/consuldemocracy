class AddProposalsTitleLegislationProcess < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :proposals_title, :string
  end
end
