require "rails_helper"

describe VerificationCensusApi do
  let(:api) { VerificationCensusApi.new }

  describe "request structure" do

    let!(:document_type) { create(:verification_field, name: "document_type") }
    let!(:document_number) { create(:verification_field, name: "document_number") }
    let!(:another_field_required) { create(:verification_field, name: "another_field_required") }

    before do
      create(:verification_handler_field_assignment, :remote_census, verification_field: document_type, request_path: "request.document_type" )
      create(:verification_handler_field_assignment, :remote_census, verification_field: document_number, request_path: "request.document_number" )
      create(:verification_handler_field_assignment, :remote_census, verification_field: another_field_required, request_path: "request.another_field_required" )
      # Setting["feature.custom_verification_process"] = true
      # Setting["remote_census.request.structure"] = "{'request': {'static_field':  1, 'document_number': nil, 'document_type': nil, 'another_field_required': nil }}"
      Setting["remote_census.request.structure"] = '{ "request":
                                                      { "static_field": "1",
                                                        "document_type": "nil",
                                                        "document_number": "nil",
                                                        "another_field_required": "nil"
                                                      }
                                                    }'
    end

    it "correctly filled with verification fields values" do
      attributes = {:document_type=>"1", :document_number=>"12345678Z", :another_field_required=>"sample_value"}

      request = VerificationCensusApi.new.send(:request, attributes)

      expect(request).to eq ({ "request" =>
                              {"static_field" => "1",
                               "document_type" => "1",
                               "document_number" => "12345678Z",
                               "another_field_required" => "sample_value" }
                              })
    end

  end

  describe "get_response_body" do

    it "return expected stubbed_response" do
      attributes = {:document_type=>"1", :document_number=>"12345678Z", :another_field_required=>"sample_value"}

      response = VerificationCensusApi.new.send(:get_response_body, attributes)

      expect(response).to eq ({ get_habita_datos_response: {
                                  get_habita_datos_return: {
                                    datos_habitante: {
                                      item: {
                                        fecha_nacimiento_string: "31-12-1980",
                                        identificador_documento: "12345678Z",
                                        descripcion_sexo: "Varón",
                                        nombre: "José",
                                        apellido1: "García"
                                      }
                                    },
                                    datos_vivienda: {
                                      item: {
                                        codigo_postal: "28013",
                                        codigo_distrito: "01"
                                      }
                                    }
                                  }
                                }
                              })
    end

  end

  describe "VerificationCensusApi::Response" do

    before do
      access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      Setting["remote_census.response.valid"] = access_user_data
    end

    it "return expected response methods with default values" do
      attributes = {:document_type=>"1", :document_number=>"12345678Z", :another_field_required=>"sample_value"}

      get_response_body = VerificationCensusApi.new.send(:get_response_body, attributes)
      response = VerificationCensusApi::Response.new(get_response_body)

      expect(response.valid?).to eq true
    end

  end

end
