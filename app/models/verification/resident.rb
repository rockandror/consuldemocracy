class Verification::Resident < ApplicationRecord
  self.table_name = "verification_residents"

  serialize :data, HashSerializer
  validates :data, presence: true, uniqueness: true
  validates :data, format: /{("\w+":(\s)*"\w+"(,)*(\s)*)*}/, if: -> { data.is_a?(String) }

  scope :search, -> (key, value) { where("data->> '#{key}' ILIKE ?", "%#{value}%") }

  def self.find_by_data(data)
    find_by("data @> ?", data.to_json)
  end
end
