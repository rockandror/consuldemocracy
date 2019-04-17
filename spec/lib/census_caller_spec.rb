require "rails_helper"

describe CensusCaller do
  let(:api) { described_class.new }

  describe "#call" do
    it "returns data from local_census_records if census API is not available" do
      census_api_response = CensusApi::Response.new(get_habita_datos_response: {
          get_habita_datos_return: { datos_habitante: {}, datos_vivienda: {} }
        }
      )

      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      expect_any_instance_of(CensusApi).to   receive(:call).and_return(census_api_response)
      expect_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

      allow(CensusApi).to   receive(:call).with(1, "12345678A")
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A", nil, nil)

      expect(response).to eq(local_census_response)
    end

    it "returns data from census API if it's available and valid" do
      census_api_response = CensusApi::Response.new(get_habita_datos_response: {
        get_habita_datos_return: {
          datos_habitante: { item: { fecha_nacimiento_string: "1-1-1980" } }
        }
      })

      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      expect_any_instance_of(CensusApi).to  receive(:call).and_return(census_api_response)
      allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

      allow(CensusApi).to receive(:call).with(1, "12345678A")
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A", nil, nil)

      expect(response).to eq(census_api_response)
    end

    it "returns data from Custom Census API if it's available and valid" do
      Setting["feature.remote_census"] = true

      custom_census_api_response = CustomCensusApi::Response.new(get_habita_datos_response: {
        get_habita_datos_return: {
          datos_habitante: { item: { fecha_nacimiento_string: "1-1-1980" } }
        }
      })

      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      expect_any_instance_of(CustomCensusApi).to receive(:call).and_return(custom_census_api_response)
      allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

      allow(CustomCensusApi).to receive(:call).with(1, "12345678A", Date.parse("01/01/1983"), "28001")
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A", Date.parse("01/01/1983"), "28001")

      expect(response).to eq(custom_census_api_response)

      Setting["feature.remote_census"] = nil
    end

    it "returns data from Custom Census API if it's available and valid without send date_of_birth and postal_code" do
      Setting["feature.remote_census"] = true

      custom_census_api_response = CustomCensusApi::Response.new(get_habita_datos_response: {
        get_habita_datos_return: {
          datos_habitante: { item: { fecha_nacimiento_string: "1-1-1980" } }
        }
      })

      local_census_response = LocalCensus::Response.new(create(:local_census_record))

      expect_any_instance_of(CustomCensusApi).to receive(:call).and_return(custom_census_api_response)
      allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

      allow(CustomCensusApi).to receive(:call).with(1, "12345678A", nil, nil)
      allow(LocalCensus).to receive(:call).with(1, "12345678A")

      response = api.call(1, "12345678A", nil, nil)

      expect(response).to eq(custom_census_api_response)

      Setting["feature.remote_census"] = nil
    end
  end

end
