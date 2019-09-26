class Verification::Value < ApplicationRecord
  self.table_name = "verification_values"
  belongs_to :user
  belongs_to :verification_field, class_name: "Verification::Field"

  validates :value, presence: true, if: -> { self.verification_field.required? }
end
