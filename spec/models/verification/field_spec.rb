require "rails_helper"

describe Verification::Field do
  let(:field) { build(:verification_field) }

  it "Should be valid" do
    expect(field).to be_valid
  end

  it "Should not be valid without name" do
    field.name = nil

    expect(field).not_to be_valid
  end

  it "Should not be valid without label" do
    field.label = nil

    expect(field).not_to be_valid
  end

  it "Should not be valid without position" do
    field.position = nil

    expect(field).not_to be_valid
  end

  describe ".required" do
    it "Should return only required fields" do
      required_field = create :verification_field, required: true
      create :verification_field, required: false

      expect(described_class.required).to eq([required_field])
    end
  end
end
