require "rails_helper"

describe Verification::Handlers::Response do
  describe "#success?" do
    it "returns true when response is initialized to true" do
      response = described_class.new(true, "success")

      expect(response.success?).to be true
    end

    it "returns false when response is initialized to false" do
      response = described_class.new(false, "error")

      expect(response.success?).to be false
    end
  end

  describe "#error?" do
    it "returns true when response is initialized to true" do
      response = described_class.new(true, "success")

      expect(response.error?).to be false
    end

    it "returns false when response is initialized to false" do
      response = described_class.new(false, "error")

      expect(response.error?).to be true
    end
  end
end
