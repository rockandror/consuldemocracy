require "rails_helper"

describe Verification::Field::Option do
  let(:option) { build(:verification_field_option) }

  it "is valid" do
    expect(option).to be_valid
  end

  it "is not valid without a label" do
    option.label = nil

    expect(option).not_to be_valid
  end

  it "is not valid without a value" do
    option.value = nil

    expect(option).not_to be_valid
  end
end
