require "rails_helper"

describe Verification::Value do
  let(:verification_value) { build(:verification_value) }

  it "is valid" do
    expect(verification_value).to be_valid
  end

  it "is valid without value when verification_field is not required" do
    verification_value.value = nil

    expect(verification_value).to be_valid
  end

  it "is not valid without value when verification_field is required" do
    verification_value.verification_field.update(required: true)
    verification_value.value = nil

    expect(verification_value).not_to be_valid
  end

  it "deletegates user to related verification process" do
    verification_value.verification_field.update(required: true)
    verification_value.value = nil

    expect(verification_value.user).to eq(verification_value.verification_process.user)
  end
end
