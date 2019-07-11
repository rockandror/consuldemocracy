class CreateVerificationFields < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_fields do |t|
      t.string :name
      t.string :label
      t.integer :position
      t.string :controller
      t.boolean :required
    end
    add_index :verification_fields, :controller
  end
end
