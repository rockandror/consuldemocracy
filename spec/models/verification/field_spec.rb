require "rails_helper"

describe Verification::Field do
  let(:model) { Verification::Field }
  let(:field) { build(:verification_field) }

  it "is be valid" do
    expect(field).to be_valid
  end

  it "is not be valid without name" do
    field.name = nil

    expect(field).not_to be_valid
  end

  it "is not valid without label" do
    field.label = nil

    expect(field).not_to be_valid
  end

  it "is not valid without position" do
    field.position = nil

    expect(field).not_to be_valid
  end

  it "is not valid without kind" do
    field.kind = nil

    expect(field).not_to be_valid
  end

  describe ".required" do
    it "returns only required fields" do
      required_field = create :verification_field, required: true
      create :verification_field, required: false

      expect(model.required).to eq([required_field])
    end
  end

  describe ".confirmation_validation" do
    it "returns only confirmation_validation fields" do
      confirmation_validation_field = create :verification_field, confirmation_validation: true
      create :verification_field, confirmation_validation: false

      expect(model.confirmation_validation).to eq([confirmation_validation_field])
    end
  end

  describe ".with_format" do
    it "returns only with_format fields" do
      with_format_field = create :verification_field, format: "format_defined"
      create :verification_field, format: ""

      expect(model.with_format).to eq([with_format_field])
    end
  end

  describe ".with_checkbox_required" do
    it "returns only with_checkbox_required fields" do
      with_checkbox_required_field = create :verification_field, kind: "checkbox", required: true
      create :verification_field, kind: "text", required: true
      create :verification_field, kind: "checkbox", required: false

      expect(model.with_checkbox_required).to eq([with_checkbox_required_field])
    end
  end

  describe ".visible" do
    it "return only visible fields" do
      visible_field = create :verification_field, visible: true
      create :verification_field, visible: false

      expect(model.visible).to eq([visible_field])
    end
  end
end
