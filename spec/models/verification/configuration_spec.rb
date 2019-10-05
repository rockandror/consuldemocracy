require "rails_helper"

describe Verification::Configuration do
  let!(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler
    end
  end

  before do
    Setting["custom_verification_process.remote_census"] = true
    Setting["custom_verification_process.residents"] = true
    Setting["custom_verification_process.sms"] = true
    Setting["custom_verification_process.my_handler"] = true
  end

  describe ".available_handlers" do
    it "should return registered handlers" do
      defined_handlers = { "my_handler" => handler, "sms" => Verification::Handlers::Sms }

      expect(described_class.available_handlers).to include(defined_handlers)
    end
  end

  describe ".active_handlers_ids" do
    it "should return registered handlers ids" do
      expect(described_class.active_handlers_ids).to include("sms", "remote_census", "residents", "my_handler")
    end
    it "should not return inactive handlers id" do
      Setting["custom_verification_process.remote_census"] = false
      expect(described_class.active_handlers_ids).not_to include("remote_census")
    end
  end

  describe ".active_handlers" do
    it "should return only active handlers" do
      field = create(:verification_field, name: "phone")
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
      create(:verification_handler_field_assignment, verification_field: field, handler: :my_handler)

      expect(described_class.active_handlers).to eq(["sms", "my_handler"])
    end
  end

  describe ".required_confirmation_handlers" do
    let(:without_confirmation_handler) do
      Class.new(Verification::Handler) do
        register_as :my_handler
      end
    end

    it "should return handlers which requires user confirmation" do
      handler.class_eval do
        requires_confirmation true
      end

      expect(described_class.required_confirmation_handlers).to include({ "my_handler" => handler })
      expect(described_class.required_confirmation_handlers).not_to include without_confirmation_handler
    end
  end

  describe ".confirmation_fields" do
    let!(:field) { create(:verification_field, name: "phone") }

    it "should return confirmation fields names for handlers in use" do
      create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
      create(:verification_handler_field_assignment, verification_field: field, handler: :my_handler)
      handler.class_eval do
        requires_confirmation true
      end

      confirmation_fields = described_class.confirmation_fields

      expect(confirmation_fields).to include("sms_confirmation_code", "my_handler_confirmation_code")
    end
  end
end
