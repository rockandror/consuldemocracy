class CensusCaller

  def call(document_type, document_number, date_of_birth, postal_code)
    response = if Setting["feature.remote_census"].present?
                 RemoteCensusApi.new.call(document_type, document_number, date_of_birth, postal_code)
               elsif Setting["feature.legacy_remote_census"].present?
                 CensusApi.new.call(document_type, document_number)
               end

    response = LocalCensus.new.call(document_type, document_number) unless response&.valid?

    response
  end
end
