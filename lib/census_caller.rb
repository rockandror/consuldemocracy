class CensusCaller

  def call(document_type, document_number)

    return Response.new if document_number.blank? || document_type.blank?

    #response = CensusApi.new.call(document_type, document_number)
    #response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response = LocalCensus.new.call(document_type, document_number)

    response
  end

  class Response
    def valid?
      false
    end
  end  
end
