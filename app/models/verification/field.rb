class Verification::Field < ApplicationRecord
  self.table_name = "verification_fields"

  enum kind: { text: 0, checkbox: 1, selector: 2, date: 3 }

  translates :label, touch: true
  translates :hint, touch: true
  include Globalizable

  has_many :verification_values, class_name: "Verification::Value",
                                 foreign_key: :verification_field_id,
                                 inverse_of: :verification_field,
                                 dependent: :destroy
  has_many :options, foreign_key: :verification_field_id,
                     inverse_of: :verification_field,
                     dependent: :destroy
  has_many :assignments, class_name: "Verification::Handler::FieldAssignment",
                         foreign_key: :verification_field_id,
                         inverse_of: :verification_field,
                         dependent: :destroy

  accepts_nested_attributes_for :options, reject_if: :all_blank, allow_destroy: true

  validates_translation :label, presence: true, length: { minimum: 2 }
  validates :name, presence: true
  validates :position, presence: true
  validates :kind, presence: true

  scope :required, -> { where(required: true) }
  scope :confirmation_validation, -> { where(confirmation_validation: true) }
  scope :with_format, -> { where.not(format: [nil, ""]) }
  scope :with_checkbox_required, -> { checkbox.where(required: true) }
  scope :visible, -> { where(visible: true) }

  def handlers
    assignments.collect(&:handler)
  end
end
