require "rails_helper"

describe Verification::Confirmation do
  before do
    Setting["custom_verification_process.sms"] = true
    field = create(:verification_field, name: :phone)
    create(:verification_field_assignment, verification_field: field, handler: :sms)
  end

  context "Validations" do
    let(:confirmation) { build(:verification_confirmation) }

    it "When required confirmation codes are present and coincident it should be valid" do
      confirmation.sms_confirmation_code = "CODE"
      confirmation.user.update!(sms_confirmation_code: "CODE")

      expect(confirmation).to be_valid
    end

    it "When confirmation codes are not present it should not be valid" do
      expect(confirmation).not_to be_valid
    end

    it "When confirmation codes are present but do not match it should not be
        valid" do
      confirmation.sms_confirmation_code = "BADCODE"
      confirmation.user.update!(sms_confirmation_code: "CODE")

      expect(confirmation).not_to be_valid
    end

    it "When no user is defined it should not be valid" do
      confirmation.user = nil

      expect(confirmation).not_to be_valid
    end
  end

  describe "#save" do
    before do
      field = create(:verification_field, name: "phone")
      create(:verification_field_assignment, verification_field: field, handler: "sms")
      Setting["custom_verification_process.sms"] = true
    end

    let(:user)         { create(:user) }
    let!(:process)     { create(:verification_process, user: user, phone: "333444555") }
    let(:confirmation) { build(:verification_confirmation, user: user) }

    it "When all confirmation codes matches it should mark verification process as verified" do
      confirmation.sms_confirmation_code = user.reload.sms_confirmation_code

      expect do
        confirmation.save
      end.to change { process.reload.verified_at }.from(nil).to(Time)
    end

    it "When all confirmation codes matches and phone is really verified through sms 'Handler'
        it should mark verification process as phone_verified also" do
      confirmation.sms_confirmation_code = user.reload.sms_confirmation_code
      expect do
        confirmation.save
      end.to change { process.reload.phone_verified_at }.from(nil).to(Time)
    end
  end
end
