class CreateVerificationHandlerFieldAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :verification_handler_field_assignments do |t|
      t.references :verification_field, index: { name: :index_field_assignments_on_field_id }, foreign_key: true
      t.string :handler, index: { name: :index_field_assignments_on_handler }, null: false

      t.timestamps null: false
    end
  end
end
