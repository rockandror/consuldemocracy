require "rails_helper"

describe Verification::Field::Option do
  let(:option) { build(:verification_field_option) }

  it "Should be valid" do
    expect(option).to be_valid
  end

  it "Should not be valid without label" do
    option.label = nil

    expect(option).not_to be_valid
  end

  it "Should not be valid without value" do
    option.value = nil

    expect(option).not_to be_valid
  end

end
