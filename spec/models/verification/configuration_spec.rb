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
    it "return registered handlers" do
      defined_handlers = { "my_handler" => handler, "sms" => Verification::Handlers::Sms }

      expect(Verification::Configuration.available_handlers).to include(defined_handlers)
    end
  end

  describe ".active_handlers_ids" do
    it "return all enabled registered handlers ids" do
      expected_handler_ids = ["sms", "remote_census", "residents", "my_handler"]
      expect(Verification::Configuration.active_handlers_ids).to include(*expected_handler_ids)

      Setting["custom_verification_process.remote_census"] = false
      expect(Verification::Configuration.active_handlers_ids).not_to include("remote_census")
    end
  end

  describe ".active_handlers" do
    it "return only active handlers" do
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)
      create(:verification_field_assignment, verification_field: field, handler: :my_handler)

      expect(Verification::Configuration.active_handlers).to eq(["sms", "my_handler"])
    end
  end

  describe ".required_confirmation_handlers" do
    let(:without_confirmation_handler) do
      Class.new(Verification::Handler) do
        register_as :without_confirmation_handler
      end
    end
    let(:required_confirmation_handler) do
      Class.new(Verification::Handler) do
        register_as :required_confirmation_handler
        requires_confirmation true
      end
    end

    it "return enabled and active handlers which requires a confirmation code" do
      handler.class_eval do
        requires_confirmation true
      end
      create(:verification_field_assignment, handler: :my_handler)

      handlers = Verification::Configuration.required_confirmation_handlers
      expect(handlers).to include({ "my_handler" => handler })
      expect(handlers).not_to include({ "without_confirmation_handler" => without_confirmation_handler })
      expect(handlers).not_to include({ "required_confirmation_handler" => required_confirmation_handler })
    end
  end

  describe ".confirmation_fields" do
    let!(:field) { create(:verification_field, name: "phone") }

    it "return confirmation fields names for handlers in use" do
      create(:verification_field_assignment, verification_field: field, handler: :sms)
      create(:verification_field_assignment, verification_field: field, handler: :my_handler)
      handler.class_eval do
        requires_confirmation true
      end

      confirmation_fields = Verification::Configuration.confirmation_fields

      expect(confirmation_fields).to include("sms_confirmation_code", "my_handler_confirmation_code")
    end
  end
end
