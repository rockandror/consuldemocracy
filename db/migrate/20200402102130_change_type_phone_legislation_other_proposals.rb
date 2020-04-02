class ChangeTypePhoneLegislationOtherProposals < ActiveRecord::Migration[5.0]
  def change
    change_column :legislation_other_proposals, :phone, :text
  end
end
