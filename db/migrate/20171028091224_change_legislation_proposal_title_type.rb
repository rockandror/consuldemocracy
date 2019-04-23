class ChangeLegislationProposalTitleType < ActiveRecord::Migration[4.2]
  def change
    change_column :legislation_proposals, :title, :text
  end
end
