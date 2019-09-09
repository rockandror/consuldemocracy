class Verification::Resident < ApplicationRecord
  self.table_name = "verification_residents"

  validates :data, presence: true, uniqueness: true

  def self.find_by_data(data)
    find_by("data @> ?", data.to_json)
  end
end
