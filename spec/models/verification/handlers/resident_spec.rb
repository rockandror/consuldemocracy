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
      create(:verification_handler_field_assignment, verification_field: document_number_field,
        handler: :resident)
      create(:verification_handler_field_assignment, verification_field: postal_code_field,
        handler: :resident)
    end

    it "returns error response when unique phone validation fails" do
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
  end
end
