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
      field = create(:verification_field, name: :custom_field_name)
      create(:verification_handler_field_assignment, verification_field: field, handler: :handler)

      expect(process.save).to be(true)
    end

    it "should save one verification value for each verification field" do
      create(:verification_field, name: :custom_field_name)

      expect{ process.save }.to change{ Verification::Value.count}.by(1)
    end
  end

  describe "#verified?" do
    let(:process) { create(:verification_process) }

    it "is false when process verified_at is not present" do
      expect(process.verified?).to be(false)
    end

    it "is true when process verified_at is defined" do
      process.update(verified_at: Time.current)

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
end
