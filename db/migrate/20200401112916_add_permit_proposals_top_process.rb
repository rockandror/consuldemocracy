class AddPermitProposalsTopProcess < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :permit_proposals_top_relevance, :boolean
  end
end
