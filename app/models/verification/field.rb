class Verification::Field < ApplicationRecord
  self.table_name = "verification_fields"

  validates :controller, presence: true
  validates :name, presence: true
  validates :label, presence: true
  validates :position, presence: true
end
