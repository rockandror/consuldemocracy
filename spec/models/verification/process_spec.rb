require "rails_helper"

describe Verification::Process do
  before { Setting["feature.custom_verification_process"] = true }
  let(:model) { Verification::Process }
  let(:process) { build(:verification_process) }

  it "Is valid" do
    expect(process).to be_valid
  end

  it "Is not valid without a user defined" do
    process.user = nil

    expect(process).not_to be_valid
  end

  describe "#initialize" do
    it "Build a new instance with given attributes" do
      create(:verification_field, name: :date, kind: :date)
      date = Date.current
      process = model.new(date: date)

      expect(process.date).to eq(date)
    end

    it "Create one attribute accessor per defined verification field" do
      create(:verification_field, name: :custom_field_name)

      expect(process).to respond_to(:custom_field_name)
      expect(process).to respond_to(:custom_field_name=)
    end

    it "Create one confirmation attribute accessor per defined verification field" do
      create(:verification_field, name: :custom_field_name, confirmation_validation: true)

      expect(process).to respond_to(:custom_field_name_confirmation)
      expect(process).to respond_to(:custom_field_name_confirmation=)
    end

    it "Add presence validation to attribute accessor when related verification field is required" do
      create(:verification_field, name: :required_field_name, required: true)

      process.required_field_name = nil

      expect(process).not_to be_valid
      expect(process.errors[:required_field_name]).to include("can't be blank")
      process.required_field_name = "Something to pass validation"
      expect(process).to be_valid
    end

    it "Add confirmation validation to attribute accessor when related verification field
        confirmation_validation is enabled" do
      create(:verification_field, name: :name, confirmation_validation: true)

      process.name = "James Bond"
      process.name_confirmation = "James Bond 007"

      expect(process).not_to be_valid
      expect(process.errors[:name_confirmation]).to include("doesn't match Name")
      process.name_confirmation = "James Bond"
      expect(process).to be_valid
    end

    it "Add format validation to attribute accessor when related verification field
        has a format validation defined" do
      create(:verification_field, name: :phone, format: '\A[\d \+]+\z')

      process.phone = "wrong format"

      expect(process).not_to be_valid
      expect(process.errors[:phone]).to include("is invalid")
      process.phone = "666777888"
      expect(process).to be_valid
    end

    it "Add acceptance validation to attribute accessor when related verification field
        is required and has kind 'checkbox'" do
      create(:verification_field, name: :tos, required: true, kind: :checkbox)

      process.tos = "0"
      expect(process).not_to be_valid
      expect(process.errors[:tos]).to include("must be accepted")
      process.tos = "1"
      expect(process).to be_valid
    end

    # TODO: Check dates parsing
  end

  describe "#before_create" do
    before { Setting["custom_verification_process.residents"] = true }

    it "will call handlers_verification method when there is not validation errors" do
      create(:verification_field, name: :custom_field)

      expect(process).to receive(:handlers_verification)
      expect(process.save).to be(true)
    end

    it "wont call handlers_verification method when there is any validation error" do
      create(:verification_field, name: :custom_field, required: true)

      expect(process).not_to receive(:handlers_verification)
      expect(process.save).to be(false)
    end

    it "stops saving the process when any handler verification responds with an error" do
      field = create(:verification_field, name: :custom_field)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      expect(process.save).to be(false)
    end

    it "copy errors from errored handlers to process :base" do
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      error = "The Census was unable to verify your information. Please confirm "   \
              "that your census details are correct by calling to City Council or " \
              "visit one Citizen Support Office."
      expect do
        process.save
      end.to change { process.errors[:base] }.from([]).to([[error]])
    end

    it "converts :date fields to a string with defined format" do
      Setting["custom_verification_process.residents"] = true
      Verification::Field.destroy_all
      field = create(:verification_field, name: :date, kind: :date)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents,
                                                     format: "%d/%m/%Y")
      process = build(:verification_process, date: Date.current)

      expected_arguments = { date: process.date.strftime("%d/%m/%Y"), user: process.user }
      expect_any_instance_of(Verification::Handlers::Resident).
        to receive(:verify).with(expected_arguments).and_call_original
      process.save
    end

    it "convert date fields to a string with date ISO 8601 '%F' when format is not defined" do
      Setting["custom_verification_process.residents"] = true
      Verification::Field.destroy_all
      field = create(:verification_field, name: :date, kind: :date)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)
      process = build(:verification_process, date: Date.current)

      expected_arguments = { date: process.date.strftime("%F"), user: process.user }
      expect_any_instance_of(Verification::Handlers::Resident).
        to receive(:verify).with(expected_arguments).and_call_original
      process.save
    end
  end

  describe "#after_create" do
    it "saves one verification value for each verification field" do
      create(:verification_field, name: :custom_field_name)

      expect { process.save }.to change { Verification::Value.count }.by(1)
    end

    it "marks process as verified when process do not need any confirmation codes" do
      create(:verification_resident, data: { document_number: "4433221Z" })
      field = create(:verification_field, name: :document_number)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      process.document_number = "4433221Z"

      expect { process.save }.to change { process.verified_at }.from(nil).to(Time)
    end

    it "do not mark process as verified when any of the active handlers requires confirmation" do
      field = create(:verification_field, name: :phone)
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)

      process.phone = "666444000"

      expect { process.save }.to change { process.verified_at }.from(nil).to(Time)
    end

    it "marks residence_verified_at with current time when Resident verification handler is enabled" do
      Setting["custom_verification_process.residents"] = true
      create(:verification_resident, data: { document_number: "4433221Z" })
      field = create(:verification_field, name: :document_number)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      process.document_number = "4433221Z"

      expect { process.save }.to change { process.residence_verified_at }.from(nil).to(Time)
    end

    it "marks residence_verified_at with current time when RemoteCensus verification handler is enabled" do
      Setting["custom_verification_process.remote_census"] = true
      chain = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      Setting["remote_census.response.valid"] = chain
      document_number_field = create(:verification_field, name: :document_number)
      document_type_field = create(:verification_field, name: :document_type)
      create(:verification_handler_field_assignment, verification_field: document_number_field,
                                                     handler: :remote_census)
      create(:verification_handler_field_assignment, verification_field: document_type_field,
                                                     handler: :remote_census)

      process.document_number = "12345678Z"
      process.document_type = "1"

      expect { process.save }.to change { process.residence_verified_at }.from(nil).to(Time)
    end
  end

  describe "#after_find"

  describe "#requires_confirmation?" do
    before do
      Setting["custom_verification_process.sms"] = true
      Setting["custom_verification_process.residents"] = true
    end

    it "when any of the active handlers requires confirmation it should return true" do
      field = create(:verification_field, name: :phone)

      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)

      expect(process.requires_confirmation?).to be(true)
    end

    it "when none of the active handlers requires confirmation it should return false" do
      field = create(:verification_field, name: :field)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      expect(process.requires_confirmation?).to be(false)
    end
  end

  describe "#confirmations_pending?" do
    it "is false when process confirmed_at is already set" do
      process = create(:verification_process)

      expect(process.confirmations_pending?).to be(false)
    end

    it "is false when process confirmed_at is already set" do
      process = create(:verification_process, confirmed_at: Time.current)

      expect(process.confirmations_pending?).to be(false)
    end

    it "is true when process confirmed_at is not defined and process requires confirmation" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: :phone)
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
      process.phone = "333444555"
      process.save!

      expect(process.confirmations_pending?).to be(true)
    end
  end

  describe "#verified?" do
    let(:process) { build(:verification_process) }

    it "is false when process verified_at is not present" do
      expect(process.verified?).to be(false)
    end

    it "is true when process verified_at is defined" do
      expect { process.save }.to change { process.verified? }

      expect(process.verified?).to be(true)
    end
  end

  describe "#verified_phone?" do
    let(:process) { create(:verification_process) }

    it "is false when process phone_verified_at is not present" do
      expect(process.verified_phone?).to be(false)
    end

    it "is true when process phone_verified_at is defined" do
      process.update!(phone_verified_at: Time.current)

      expect(process.verified_phone?).to be(true)
    end
  end

  describe "#verified_residence?" do
    let(:process) { create(:verification_process) }

    it "is false when process residence_verified_at is not present" do
      expect(process.verified_residence?).to be(false)
    end

    it "is true when process residence_verified_at is defined" do
      process.update!(residence_verified_at: Time.current)

      expect(process.verified_residence?).to be(true)
    end
  end

  describe "#confirmed?" do
    let(:process) { build(:verification_process) }

    it "is false when process confirmed_at is not present" do
      expect(process.confirmed?).to be(false)
    end

    it "is true when process confirmed_at is defined" do
      process.save!

      expect(process.confirmed?).to be(true)
    end
  end
end
