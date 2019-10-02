class Verification::Field < ApplicationRecord
  self.table_name = "verification_fields"

  translates :label, touch: true
  translates :hint, touch: true
  include Globalizable

  has_many :verification_values, class_name: "Verification::Value", foreign_key: :verification_field_id
  has_many :assignments, class_name: "Verification::Handler::FieldAssignment",
                         foreign_key: :verification_field_id,
                         dependent: :destroy

  validates_translation :label, presence: true, length: { minimum: 2 }
  validates :name, presence: true
  validates :position, presence: true

  scope :required, -> { where(required: true) }
  scope :confirmation_validation, -> { where(confirmation_validation: true) }
  scope :with_response_path, -> { where.not(response_path: [nil, ""]) }
  scope :with_format, -> { where.not(format: [nil, '']) }

  def handlers
    assignments.collect(&:handler)
  end
end
