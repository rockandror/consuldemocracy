require "rails_helper"

describe Verification::Confirmation do
  before do
    Setting["custom_verification_process.sms"] = true
    field = create(:verification_field, name: :phone)
    create(:verification_handler_field_assignment, verification_field: field, handler: :sms)
  end

  context "Validations" do
    let(:confirmation) { build(:verification_confirmation) }

    it "When required confirmation codes are present and coincident it should be valid" do
      confirmation.sms_confirmation_code = "CODE"
      confirmation.user.update(sms_confirmation_code: "CODE")

      expect(confirmation).to be_valid
    end

    it "When confirmation codes are not present it should not be valid" do
      expect(confirmation).not_to be_valid
    end

    it "When confirmation codes are present but do not match it should not be
        valid" do
      confirmation.sms_confirmation_code = "BADCODE"
      confirmation.user.update(sms_confirmation_code: "CODE")

      expect(confirmation).not_to be_valid
    end

    it "When no user is defined it should not be valid" do
      confirmation.user = nil

      expect(confirmation).not_to be_valid
    end
  end
end
