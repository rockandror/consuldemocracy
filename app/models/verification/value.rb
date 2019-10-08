class Verification::Value < ApplicationRecord
  self.table_name = "verification_values"

  belongs_to :verification_process, class_name: "Verification::Process"
  belongs_to :verification_field, class_name: "Verification::Field"

  validates :verification_process, presence: true
  validates :value, presence: true, if: -> { self.verification_field.required? }

  delegate :user, to: :verification_process
end
