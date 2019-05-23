class LocalCensusRecord < ApplicationRecord
  DUPLICATED_QUERY = "LOWER(local_census_records.document_type) = ? AND " \
                     "LOWER(local_census_records.document_number) = ? AND " \
                     "date_of_birth = ? AND " \
                     "LOWER(local_census_records.postal_code) = ?"

  before_validation :sanitize

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validate :duplicated_record

  scope :search,  -> (terms) { where("document_number ILIKE ?", "%#{terms}%") }

  private

    def sanitize
      self.document_type   = self.document_type&.strip
      self.document_number = self.document_number&.strip
      self.postal_code     = self.postal_code&.strip
    end

    def duplicated_record
      return unless LocalCensusRecord.find_by(DUPLICATED_QUERY,
        document_type&.downcase,
        document_number&.downcase,
        date_of_birth,
        postal_code&.downcase)

      errors.add :base, :duplicated_record
    end
end
