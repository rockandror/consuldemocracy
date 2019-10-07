require "rails_helper"

describe Verification::Process do
  let(:process) { build(:verification_process) }

  it "Should be valid" do
    expect(process).to be_valid
  end

  it "When no user is defined it should not be valid" do
    process.user = nil

    expect(process).not_to be_valid
  end

  describe "required_fields validation" do
    it "When required fields defined are not present it should not be valid" do
      create(:verification_field, name: :custom_field, required: true)

      expect(process).not_to be_valid
    end

    it "When required fields defined are present it should be valid" do
      create(:verification_field, name: :custom_field, required: true)
      process.custom_field = "some_value"

      expect(process).to be_valid
    end
  end

  describe "confirmation field validation" do
    it "When confirmation validation field is not present it should not be valid" do
      create(:verification_field, name: :custom_field, confirmation_validation: true)
      process.custom_field = "some_value"
      process.custom_field_confirmation = ""

      expect(process).not_to be_valid
    end

    it "When confirmation validation field is present but is not equal it should not be valid" do
      create(:verification_field, name: :custom_field, confirmation_validation: true)
      process.custom_field = "some_value"
      process.custom_field_confirmation = "another_value"

      expect(process).not_to be_valid
    end

    it "When confirmation validation field is equal it should be valid" do
      create(:verification_field, name: :custom_field, confirmation_validation: true)
      process.custom_field = "some_value"
      process.custom_field_confirmation = "some_value"

      expect(process).to be_valid
    end
  end

  describe "format validation" do
    it "With wrong format it should not be valid" do
      create(:verification_field, name: :custom_field, format: '\A[\d \+]+\z')
      process.custom_field = "wrong format"

      expect(process).not_to be_valid
    end

    it "With correct format it should be valid" do
      create(:verification_field, name: :custom_field, format: '\A[\d \+]+\z')
      process.custom_field = "666999999"

      expect(process).to be_valid
    end
  end

  describe "checkbox fields validation" do
    it "When checkbox fields with required defined are not checked it should not be valid" do
      create(:verification_field, name: :custom_field, required: true, is_checkbox: true)
      process.custom_field = false

      expect(process).not_to be_valid
    end

    it "When checkbox fields with required defined are checked it should be valid" do
      create(:verification_field, name: :custom_field, required: true, is_checkbox: true)
      process.custom_field = true

      expect(process).to be_valid
    end
  end

  describe "handlers_verification validation" do
    before do
      Class.new(Verification::Handler) do
        register_as :handler

        validates :email_confirmation, presence: true
        validates :email, confirmation: { case_sensitive: false }

        def self.model_name
          ActiveModel::Name.new(self, nil, "temp")
        end
      end
      Setting["custom_verification_process.handler"] = true
      email_field = create(:verification_field, name: :email)
      email_confirmation_field = create(:verification_field, name: :email_confirmation)
      create(:verification_handler_field_assignment, verification_field: email_field, handler: :handler)
      create(:verification_handler_field_assignment, verification_field: email_confirmation_field, handler: :handler)
    end

    it "respond with a verification error it should not be valid" do
      process = build(:verification_process, email: "user@email.com",
        email_confirmation: "another_user@email.com" )

      expect(process).not_to be_valid
    end

    it "respond with a successful verification it should be valid" do
      process = build(:verification_process, email: "user@email.com",
        email_confirmation: "user@email.com" )

      expect(process).to be_valid
    end
  end

  describe "fields accessors" do
    it "should include attr accessor for each verification field defined" do
      create(:verification_field, name: :custom_field_name)

      expect(process).to respond_to(:custom_field_name)
      expect(process).to respond_to(:custom_field_name=)
    end

    it "should not include attr accessor when no field with given name defined" do
      expect(process).not_to respond_to(:custom_field_name)
    end
  end

  describe "#requires_confirmation?" do
    it "should return true when any of the active handlers requires confirmation" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false
      end
      Class.new(Verification::Handler) do
        register_as :handler_with_required_confirmation
        requires_confirmation true
      end
      Setting["custom_verification_process.handler"] = true
      Setting["custom_verification_process.handler_with_required_confirmation"] = true
      custom_field = create(:verification_field, name: :custom_field)
      other_custom_field = create(:verification_field, name: :other_custom_field)

      create(:verification_handler_field_assignment, verification_field: custom_field, handler: :handler)
      create(:verification_handler_field_assignment, verification_field: other_custom_field, handler: :handler_with_required_confirmation)

      expect(process.requires_confirmation?).to be(true)
    end

    it "should return false when none of the active handlers requires confirmation" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false
      end
      Setting["custom_verification_process.handler"] = true
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :handler)

      expect(process.requires_confirmation?).to be(false)
    end
  end

  describe "#save" do
    it "should return false when any handler response is error" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false

        def verify(attributes = {})
          Verification::Handlers::Response.new false, "Error", attributes, nil
        end
      end
      Setting["custom_verification_process.handler"] = true
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :handler)

      expect(process.save).to be(false)
    end

    it "should contain errors from errored handlers responses at :base" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false

        def verify(attributes = {})
          Verification::Handlers::Response.new false, "Verification error explanation", attributes, nil
        end
      end
      Setting["custom_verification_process.handler"] = true
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :handler)

      expect{process.save}.to change{ process.errors[:base] }.from([]).to([["Verification error explanation"]])
    end

    it "should return true when all handlers response are successful" do
      Class.new(Verification::Handler) do
        register_as :handler
      end
      Class.new(Verification::Handler) do
        register_as :other_handler
      end
      Setting["custom_verification_process.handler"] = true
      Setting["custom_verification_process.other_handler"] = true
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :handler)

      expect(process.save).to be(true)
    end

    it "saves one verification value for each verification field" do
      create(:verification_field, name: :custom_field_name)

      expect { process.save }.to change { Verification::Value.count }.by(1)
    end
  end

  describe "#after_save" do
    it "marks verified_at with current time when process do not need any confirmation codes" do
      create(:verification_resident, data: { document_number: "4433221Z" })
      field = create(:verification_field, name: :document_number)
      create(:verification_handler_field_assignment, verification_field: field, handler: :residents)

      process.document_number = "4433221Z"

      expect { process.save }.to change { process.verified_at }.from(nil).to(Time)
    end

    it "do not mark verified_at when any handler with required confirmation is enabled" do
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

  describe "#verified?" do
    let(:process) { build(:verification_process) }

    it "is false when process verified_at is not present" do
      expect(process.verified?).to be(false)
    end

    it "is true when process verified_at is defined" do
      process.save

      expect(process.verified?).to be(true)
    end
  end

  describe "#verified_phone?" do
    let(:process) { create(:verification_process) }

    it "is false when process phone_verified_at is not present" do
      expect(process.verified_phone?).to be(false)
    end

    it "is true when process phone_verified_at is defined" do
      process.update(phone_verified_at: Time.current)

      expect(process.verified_phone?).to be(true)
    end
  end

  describe "#verified_residence?" do
    let(:process) { create(:verification_process) }

    it "is false when process residence_verified_at is not present" do
      expect(process.verified_residence?).to be(false)
    end

    it "is true when process residence_verified_at is defined" do
      process.update(residence_verified_at: Time.current)

      expect(process.verified_residence?).to be(true)
    end
  end

  describe "#confirmed?" do
    let(:process) { build(:verification_process) }

    it "is false when process confirmed_at is not present" do
      expect(process.confirmed?).to be(false)
    end

    it "is true when process confirmed_at is defined" do
      process.save

      expect(process.confirmed?).to be(true)
    end
  end

  describe "#confirmations_pending?" do
    it "is false when process confirmed_at is already set" do
      process = create(:verification_process)

      expect(process.confirmations_pending?).to be(false)
    end

    it "is false when process confirmed_at is already set" do
      Setting["custom_verification_process.sms"] = true
      user = create(:user)
      field = create(:verification_field, name: :phone)
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
      process = build(:verification_process, user: user)
      process.phone = "333444555"
      process.save
      confirmation = build(:verification_confirmation, user: user,
        sms_confirmation_code: user.reload.sms_confirmation_code)
      confirmation.save

      expect(process.reload.confirmations_pending?).to be(false)
    end

    it "is true when process confirmed_at is not defined and process requires confirmation" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: :phone)
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
      process = build(:verification_process)
      process.phone = "333444555"
      process.save

      expect(process.confirmations_pending?).to be(true)
    end
  end
end
