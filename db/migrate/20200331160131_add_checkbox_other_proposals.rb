class AddCheckboxOtherProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_other_proposals, :justify_text_declaration_1, :boolean
    add_column :legislation_other_proposals, :justify_text_declaration_2, :boolean
  end
end
