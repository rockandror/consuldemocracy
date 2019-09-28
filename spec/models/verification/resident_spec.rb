require "rails_helper"

describe Verification::Resident do
  let(:resident) { build(:verification_resident) }

  it "Should be valid" do
    expect(resident).to be_valid
  end

  it "Should not be valid without data" do
    resident.data = nil

    expect(resident).not_to be_valid
  end

  it "Should not be valid with empty json" do
    resident.data = {}

    expect(resident).not_to be_valid
  end

  it "Should not be valid when data is assigned as bad formatted hash string respresentation" do
    resident.data = '{email=>"resident@email.com", document_number=>"12345678A"}'

    expect(resident).not_to be_valid
    expect(resident.errors[:data]).to include("Data format is invalid. An example of valid format could be: {\"key1\"=>\"value1\", \"key2\"=>\"value2\"}")
  end

  it "Should not be valid when other record with exact data exists" do
    create(:verification_resident, data: { email: "email@example.com", document_number: "XYZ" })
    resident = build(:verification_resident, data: { email: "email@example.com", document_number: "XYZ" })

    expect(resident).not_to be_valid
  end

  context "save" do
    it "Should convert well formatted hash string respresentation" do
      resident = create(:verification_resident, data: '{"email"=>"resident@email.com", "document_number"=>"12345678A"}')

      expect(resident).to be_persisted
      expect(resident.data.class).to eq(Hash)
    end
  end

  context ".find_by_data" do

    it "Should allow us to find a record created from data as string" do
      resident = create(:verification_resident, data: '{"email"=>"resident@email.com", "document_number"=>"12345678A"}')
      another_resident = create(:verification_resident, data: '{"email": "anotherresident@email.com", "document_number": "12345678B"}')

      expect(described_class.find_by_data({ email: "resident@email.com" })).to eq(resident)
      expect(described_class.find_by_data({ document_number: "12345678B" })).to eq(another_resident)
      expect(described_class.find_by_data({ email: "resident@email.com", document_number: "12345678A" })).to eq(resident)
    end

    it "Should allow us to find a record for any combination of information stored
        at data column" do
      resident = create(:verification_resident,
        data: {email: "resident@email.com", document_number: "12345678A"})
      another_resident = create(:verification_resident,
        data: {email: "anotherresident@email.com", document_number: "12345678B"})

      expect(described_class.find_by_data({ email: "resident@email.com" })).to eq(resident)
      expect(described_class.find_by_data({ document_number: "12345678B" })).to eq(another_resident)
      expect(described_class.find_by_data({ email: "resident@email.com", document_number: "12345678A" })).to eq(resident)
    end
  end

  context ".search" do
    it "Should return records with given term as value of any key of json structure" do
      resident1 = create(:verification_resident, data: { address: "1th Street" })
      resident2 = create(:verification_resident, data: { address: "2th Street" })

      expect(described_class.search(:address, "Street")).to include(resident1, resident2)
    end
  end
end
