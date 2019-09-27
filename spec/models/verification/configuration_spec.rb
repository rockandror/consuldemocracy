require "rails_helper"

describe Verification::Configuration do
  let!(:handler) do
    Class.new(Verification::Handler) do
      register_as :my_handler
    end
  end

  describe ".available_handlers" do
    it "should return registered handlers" do
      defined_handlers = { "my_handler" => handler, "sms" => Verification::Handlers::Sms }

      expect(described_class.available_handlers).to include(defined_handlers)
    end
  end

  describe ".ids" do
    it "should return registered handlers ids" do
      expect(described_class.ids).to include("sms", "my_handler")
    end
  end

  describe ".active_handlers" do
    it "should return only active handlers" do
      create(:verification_field, name: "phone", handlers: [:sms, :my_handler])

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
    let(:without_confirmation_handler) do
      Class.new(Verification::Handler) do
        register_as :my_handler
      end
    end

    it "should return confirmation fields names for handlers in use" do
      handler.class_eval do
        requires_confirmation true
      end

      confirmation_fields = described_class.confirmation_fields

      expect(confirmation_fields).to include("sms_confirmation_code", "my_handler_confirmation_code")
    end
  end
end
