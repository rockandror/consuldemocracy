class CreateVerificationProcesses < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_processes do |t|
      t.references :user, foreign_key: true, index: true
      t.datetime :verified_at
      t.datetime :phone_verified_at
      t.datetime :residence_verified_at
      t.timestamps null: false
    end
  end
end
