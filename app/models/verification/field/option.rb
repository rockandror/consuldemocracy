class Verification::Field::Option < ApplicationRecord
  self.table_name = "verification_field_options"

  translates :label, touch: true
  include Globalizable

  belongs_to :verification_field, class_name: "Verification::Field"

  validates_translation :label, presence: true, length: { minimum: 2 }
  validates :value, presence: true
end
