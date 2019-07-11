class Verification::Field < ApplicationRecord
  self.table_name = "verification_fields"

  translates :label, touch: true
  include Globalizable

  validates_translation :label, presence: true, length: { minimum: 2 }
  validates :controller, presence: true
  validates :name, presence: true
  validates :position, presence: true
end
