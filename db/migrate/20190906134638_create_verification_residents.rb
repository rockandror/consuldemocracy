class CreateVerificationResidents < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_residents do |t|
      t.jsonb :data, null: false, default: {}
    end

    add_index :verification_residents, :data, using: :gin
    add_index :verification_residents, :data, name: "unique_verification_residents_data", unique: true
  end
end
