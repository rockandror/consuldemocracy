class CreateLegislationOtherProposals < ActiveRecord::Migration[5.0]
  def change
    create_table :legislation_other_proposals do |t|
      t.references :proposals, index: true, foreign_key: true
      t.text :type
      t.text :name
      t.text :address
      t.text :phone
      t.text :agent
      t.text :agent_title
      t.boolean :citizen_entities
      t.text :cif
      t.text :entity_type
      t.timestamps
    end
  end
end

