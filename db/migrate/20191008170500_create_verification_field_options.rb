class CreateVerificationFieldOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_field_options do |t|
      t.references :verification_field, foreign_key: true, index: true
      t.string :label
      t.string :value
    end
  end
end
