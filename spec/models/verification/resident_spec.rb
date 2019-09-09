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

  it "Should not be valid when other record with exact data exists" do
    create(:verification_resident, data: { email: "email@example.com", document_number: "XYZ" })
    resident = build(:verification_resident, data: { email: "email@example.com", document_number: "XYZ" })

    expect(resident).not_to be_valid
  end
end
