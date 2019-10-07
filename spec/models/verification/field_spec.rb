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

  describe ".confirmation_validation" do
    it "Should return only confirmation_validation fields" do
      confirmation_validation_field = create :verification_field, confirmation_validation: true
      create :verification_field, confirmation_validation: false

      expect(described_class.confirmation_validation).to eq([confirmation_validation_field])
    end
  end

  describe ".with_format" do
    it "Should return only with_format fields" do
      with_format_field = create :verification_field, format: "format_defined"
      create :verification_field, format: ""

      expect(described_class.with_format).to eq([with_format_field])
    end
  end

  describe ".with_checkbox_required" do
    it "Should return only with_checkbox_required fields" do
      with_checkbox_required_field = create :verification_field, is_checkbox: true, required: true
      create :verification_field, is_checkbox: false, required: true

      expect(described_class.with_checkbox_required).to eq([with_checkbox_required_field])
    end
  end
end
