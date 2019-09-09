class Verification::Resident < ApplicationRecord
  self.table_name = "verification_residents"

  validates :data, presence: true, uniqueness: true
end
