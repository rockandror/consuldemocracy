require "rails_helper"

describe Verification::Value do
  let(:verification_value) { build(:verification_value) }

  it "Should be valid" do
    expect(verification_value).to be_valid
  end

  it "Should be valid without value when verification_field is not required" do
    verification_value.value = nil

    expect(verification_value).to be_valid
  end

  it "Should not be valid without value when verification_field is required" do
    verification_value.verification_field.update(required: true)
    verification_value.value = nil

    expect(verification_value).not_to be_valid
  end

end
