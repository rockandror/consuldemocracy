require "rails_helper"

describe Verification::Handler::FieldAssignment do
  let(:field_assignment) { build(:verification_handler_field_assignment) }

  it "Default factory should be valid" do
    expect(field_assignment).to be_valid
  end

  it "When field is not assigned it should not be valid" do
    field_assignment.verification_field = nil

    expect(field_assignment).not_to be_valid
  end

  it "When handler is not defined it should not be valid" do
    field_assignment.handler = nil

    expect(field_assignment).not_to be_valid
  end

  it "When already exists a record for same field and same handler it should not be valid" do
    field_assignment.save
    repeated_field_assignment = build(:verification_handler_field_assignment,
      handler: field_assignment.handler, verification_field: field_assignment.verification_field)

    expect(repeated_field_assignment).not_to be_valid
  end

  context "When handler is sms" do
    it "and verification field is not named exactly 'phone' it should not be valid" do
      verification_field = create(:verification_field, name: "email")
      field_assignment = build(:verification_handler_field_assignment, handler: "sms", verification_field: verification_field)

      expect(field_assignment).not_to be_valid
    end
  end
end
