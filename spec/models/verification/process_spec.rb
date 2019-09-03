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
        attr_accessor :email, :email_confirmation

        def verify
          params = {email: email, email_confirmation: email_confirmation}
          if email == email_confirmation
            build_response(params)
          else
            Verification::Handlers::Response.new false, I18n.t("verification_handler_error"), params, nil
          end
        end
      end

      create(:verification_field, name: :email, handlers: :handler)
      create(:verification_field, name: :email_confirmation, handlers: :handler)
    end

    it "respond with a verification error it should not be valid" do
      process = build(:verification_process, email: "user@email.com",
        email_confirmation: "user@email.com" )

      expect(process).to be_valid
    end

    it "respond with a successful verification it should be valid" do
      process = build(:verification_process, email: "user@email.com",
        email_confirmation: "another_user@email.com" )

      expect(process).not_to be_valid
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
    it "should return true when any ot the active handlers requires confirmation" do
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

    it "should return false when none ot the active handlers requires confirmation" do
      Class.new(Verification::Handler) do
        register_as :handler
        requires_confirmation false
      end
      create(:verification_field, name: :custom_field_name, handlers: :handler)

      expect(process.requires_confirmation?).to be(false)
    end
  end
end
