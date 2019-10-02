class Verification::Handler::FieldAssignment < ApplicationRecord
  self.table_name = "verification_handler_field_assignments"
  belongs_to :verification_field, class_name: "Verification::Field"

  validates :verification_field_id, presence: true
  validates :handler, presence: true
  validates :verification_field_id, uniqueness: { scope: :handler }
end
