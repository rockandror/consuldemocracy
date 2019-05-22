class LocalCensusRecord < ApplicationRecord
  DUPLICATED_QUERY = "LOWER(TRIM(local_census_records.document_type)) = ? AND " \
                     "LOWER(TRIM(local_census_records.document_number)) = ? AND " \
                     "date_of_birth = ? AND " \
                     "LOWER(TRIM(local_census_records.postal_code)) = ?"

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true

  validate :duplicated_record

  scope :search,  -> (terms) { where("document_number ILIKE ?", "%#{terms}%") }

  private

    def duplicated_record
      return unless LocalCensusRecord.find_by(DUPLICATED_QUERY,
        document_type&.downcase&.strip,
        document_number&.downcase&.strip,
        date_of_birth,
        postal_code&.downcase&.strip)

      errors.add :base, :duplicated_record
    end
end
