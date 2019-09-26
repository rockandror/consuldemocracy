class CreateVerificationValues < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_values do |t|
      t.integer :verification_field_id
      t.integer :user_id
      t.string :value
    end
  end
end
