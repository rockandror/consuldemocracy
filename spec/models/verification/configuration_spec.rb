require "rails_helper"

describe Verification::Configuration do
  describe ".available_handlers" do
    it "return all registered handlers" do
      defined_handlers = {
        "sms" => Verification::Handlers::Sms,
        "residents" => Verification::Handlers::Resident,
        "remote_census" => Verification::Handlers::RemoteCensus }

      expect(Verification::Configuration.available_handlers).to include(defined_handlers)
    end
  end

  describe ".active_handlers" do
    it "return handlers enabled by setting and defined at any field assignment" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)
      create(:verification_field_assignment, verification_field: field, handler: :residents)

      expect(Verification::Configuration.active_handlers).to include("sms")
      expect(Verification::Configuration.active_handlers).not_to include("residents")
    end
  end

  describe ".required_confirmation_handlers" do
    it "return active handlers gthat requires a coonfirmation step" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)

      handlers = Verification::Configuration.required_confirmation_handlers
      expect(handlers).to include({ "sms" => Verification::Handlers::Sms })
    end
  end

  describe ".confirmation_fields" do
    it "return confirmation fields names for required confirmation and active handlers" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)

      confirmation_fields = Verification::Configuration.confirmation_fields

      expect(confirmation_fields).to include("sms_confirmation_code")
    end
  end
end
