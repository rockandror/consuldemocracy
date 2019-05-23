namespace :local_census_records do
  QUERY = "MIN(id) as id, " \
          "LOWER(TRIM(document_type)) as _document_type, " \
          "LOWER(TRIM(document_number)) as _document_number, " \
          "LOWER(TRIM(postal_code)) as _postal_code, " \
          "date_of_birth"

  desc "Remove duplicated records"
  task remove_dups: :environment do
    ids = LocalCensusRecord.select(QUERY)
      .group(:_document_type, :_document_number, :date_of_birth, :_postal_code)
      .collect(&:id)

    LocalCensusRecord.where.not(id: ids).destroy_all
  end
end
