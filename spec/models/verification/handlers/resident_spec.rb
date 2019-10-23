require "rails_helper"

describe Verification::Handlers::Resident do
  it "its id is 'resident'" do
    expect(Verification::Handlers::Resident.id).to eq("residents")
  end

  it "its a handler that do not requires a confirmation code" do
    expect(Verification::Handlers::Resident.requires_confirmation?).to be false
  end

  describe "#verify" do
    let(:user) { create(:user) }
    let(:resident_handler) { Verification::Handlers::Resident.new }

    before do
      document_number_field = create(:verification_field, name: :document_number)
      postal_code_field = create(:verification_field, name: :postal_code)
      create(:verification_field_assignment, verification_field: document_number_field,
        handler: :resident)
      create(:verification_field_assignment, verification_field: postal_code_field,
        handler: :resident)
    end

    it "returns error response when not match found" do
      response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })

      expect(response.success?).not_to be true
      expect(response.error?).to be true
    end

    it "returns success response when all validation passes" do
      create(:verification_resident, data: { document_number: "55222333T", postal_code: "00700" })
      response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })

      expect(response.success?).to be true
      expect(response.error?).not_to be true
    end

    context "verification valid age" do
      let(:resident_data) do
        { document_number: "55222333T", postal_code: "00700", date_of_birth: "31/12/1980" }
      end

      it "returns success response when the age on response fields is valid" do
        create(:verification_resident, data: resident_data)
        field = create(:verification_field, name: :date_of_birth, represent_min_age_to_participate: true)
        create(:verification_field_assignment, verification_field: field, handler: :residents)

        response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })

        expect(response.success?).to be true
        expect(response.error?).not_to be true
      end

      it "returns error response when the age on response fields is not valid" do
        resident_data.merge!({ date_of_birth: "31/12/2010" })
        create(:verification_resident, data: resident_data)
        field = create(:verification_field, name: :date_of_birth, represent_min_age_to_participate: true)
        create(:verification_field_assignment, verification_field: field, handler: :residents)

        response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })

        expect(response.success?).not_to be true
        expect(response.error?).to be true
      end
    end

    context "geozone" do
      let(:resident_data) do
        { document_number: "55222333T", postal_code: "00700", district: "01" }
      end

      it "update user with geozone response successfully when exists geozone field on response" do
        create(:verification_resident, data: resident_data)
        field = create(:verification_field, name: :district, represent_geozone: true, visible: false)
        create(:verification_field_assignment, verification_field: field, handler: :residents)
        geozone = create(:geozone, :in_census)

        response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })
        user.reload

        expect(response.success?).to be true
        expect(user.geozone).to eq geozone
      end

      it "Not update user with geozone response when not exists geozone field on response" do
        create(:verification_resident, data: resident_data)
        field = create(:verification_field, name: :district, visible: false, represent_geozone: false)
        create(:verification_field_assignment, verification_field: field, handler: :residents)
        create(:geozone, :in_census)

        response = resident_handler.verify({ document_number: "55222333T", postal_code: "00700", user: user })
        user.reload

        expect(response.success?).to be true
        expect(user.geozone).to eq nil
      end
    end
  end
end
