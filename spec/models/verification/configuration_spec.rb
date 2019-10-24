require "rails_helper"

describe Verification::Configuration do
  describe ".available_handlers" do
    it "return hash with all registered handlers" do
      defined_handlers = {
        "sms" => Verification::Handlers::Sms,
        "residents" => Verification::Handlers::Resident,
        "remote_census" => Verification::Handlers::RemoteCensus }

      expect(Verification::Configuration.available_handlers).to include(defined_handlers)
    end
  end

  describe ".active_handlers" do
    it "return hash handlers enabled by setting and defined at any field assignment" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)
      create(:verification_field_assignment, verification_field: field, handler: :residents)

      expect(Verification::Configuration.active_handlers).to include({ "sms" => Verification::Handlers::Sms })
      expect(Verification::Configuration.active_handlers).
        not_to include({ "residents" => Verification::Handlers::Resident })
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
    it "return array of confirmation fields names for required confirmation and active handlers" do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: :sms)

      confirmation_fields = Verification::Configuration.confirmation_fields

      expect(confirmation_fields).to include("sms_confirmation_code")
    end
  end

  describe ".verification_fields" do
    it "return all verification fields when no given handler id" do
      phone_field = create(:verification_field, name: "phone")
      postal_code_field = create(:verification_field, name: "postal_code")

      verification_fields = Verification::Configuration.verification_fields

      expect(verification_fields).to include(phone_field)
      expect(verification_fields).to include(postal_code_field)
    end

    it "return verification fields related with given handler id" do
      phone_field = create(:verification_field, name: "phone")
      postal_code_field = create(:verification_field, name: "postal_code")
      create(:verification_field_assignment, verification_field: phone_field, handler: :sms)

      verification_fields = Verification::Configuration.verification_fields("sms")

      expect(verification_fields).to include(phone_field)
      expect(verification_fields).not_to include(postal_code_field)
    end
  end
end
