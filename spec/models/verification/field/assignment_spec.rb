require "rails_helper"

describe Verification::Field::Assignment do
  let(:model) { Verification::Field::Assignment }
  let(:field_assignment) { build(:verification_field_assignment) }

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

  context "When related field is a date" do
    let(:field) { create(:verification_field, kind: :date) }

    it "and format is not a valid ISO 8601 expression it should be valid" do
      field_assignment = build(:verification_field_assignment, verification_field: field, format: "%F")

      expect(field_assignment).to be_valid
    end

    it "and format is not a valid ISO 8601 expression it should not be valid" do
      field_assignment = build(:verification_field_assignment, verification_field: field, format: "DDMMYYYY")

      expect(field_assignment).not_to be_valid
    end
  end

  it "When already exists a record for same field and same handler it should not be valid" do
    field_assignment.save!
    repeated_field_assignment = build(:verification_field_assignment,
      handler: field_assignment.handler, verification_field: field_assignment.verification_field)

    expect(repeated_field_assignment).not_to be_valid
  end

  context "When handler is sms" do
    it "and verification field is not named exactly 'phone' it should not be valid" do
      field = create(:verification_field, name: "email")
      field_assignment = build(:verification_field_assignment, handler: "sms", verification_field: field)

      expect(field_assignment).not_to be_valid
    end
  end

  context ".by_handler" do
    it "returns fields_assignments for given handler" do
      name_field = create(:verification_field, name: "text", kind: :text)
      name_field_assignment = create(:verification_field_assignment, verification_field: name_field,
                                                                     handler: :remote_census)
      date_field = create(:verification_field, name: "date", kind: :date)
      date_field_assignment = create(:verification_field_assignment, verification_field: date_field,
                                                                     handler: :residents)

      expect(model.by_handler(:residents)).to include(date_field_assignment)
      expect(model.by_handler(:residents)).not_to include(name_field_assignment)
    end
  end
end
