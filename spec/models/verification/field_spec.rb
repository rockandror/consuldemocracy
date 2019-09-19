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

  describe "when handlers is defined" do
    let!(:my_handler) do
      Class.new(Verification::Handler) do
        register_as :my_handler
      end
    end

    it "Should be valid when defined as string" do
      field.handlers = "my_handler"

      expect(field).to be_valid
    end

    it "Should be valid when defined as Array of strings" do
      field.handlers = ["my_handler"]

      expect(field).to be_valid
    end

    it "it should be valid with many existing handlers" do
      Class.new(Verification::Handler) do
        register_as :other_handler
      end
      field.handlers = ["my_handler", "other_handler"]

      expect(field).to be_valid
    end

    it "it should not be valid if defined handlers does not exists" do
      field.handlers = [:non_existing_handler]

      expect(field).not_to be_valid
    end
  end

  describe ".required" do
    it "Should return only required fields" do
      required_field = create :verification_field, required: true
      create :verification_field, required: false

      expect(described_class.required).to eq([required_field])
    end
  end

  describe ".including_any_handlers" do
    let!(:my_handler) do
      Class.new(Verification::Handler) do
        register_as :my_handler
      end
    end
    let!(:other_handler) do
      Class.new(Verification::Handler) do
        register_as :other_handler
      end
    end

    it "Should return only fields with given handlers enabled" do
      handler_field = create :verification_field, handlers: "my_handler"
      other_handler_field = create :verification_field, handlers: "other_handler"

      expect(described_class.including_any_handlers(["my_handler"])).to include(handler_field)
      expect(described_class.including_any_handlers(["my_handler"])).not_to include(other_handler_field)
    end
  end
end
