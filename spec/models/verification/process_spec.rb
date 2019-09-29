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

      create(:verification_field, name: :email, handlers: :handler)
      create(:verification_field, name: :email_confirmation, handlers: :handler)
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
      create(:verification_field, name: :custom_field, handlers: :handler)
      create(:verification_field, name: :other_custom_field, handlers: :handler_with_required_confirmation)

      expect(process.requires_confirmation?).to be(true)
    end

    it "should return false when none of the active handlers requires confirmation" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false
      end
      create(:verification_field, name: :custom_field_name, handlers: :handler)

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
      create(:verification_field, name: :custom_field_name, handlers: :handler)

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
      create(:verification_field, name: :custom_field_name, handlers: :handler)

      expect{process.save}.to change{ process.errors[:base] }.from([]).to([["Verification error explanation"]])
    end

    it "should return true when all handlers response are successful" do
      Class.new(Verification::Handler) do
        register_as :handler

        def verify(attributes = {})
          Verification::Handlers::Response.new true, "Success", attributes, nil
        end
      end
      Class.new(Verification::Handler) do
        register_as :other_handler

        def verify(attributes = {})
          Verification::Handlers::Response.new true, "Success", attributes, nil
        end
      end
      create(:verification_field, name: :custom_field_name, handlers: :handler)

      expect(process.save).to be(true)
    end
  end
end
