require "rails_helper"

describe Verification::Handlers::Sms do
  it "its id is 'sms'" do
    expect(Verification::Handlers::Sms.id).to eq("sms")
  end

  it "its a handler that requires a confirmation code" do
    expect(Verification::Handlers::Sms.requires_confirmation?).to be true
  end

  it "when there is already another user with same phone it should not be valid" do
    field = create(:verification_field, name: :phone)
    create(:verification_field_assignment, verification_field: field, handler: :sms)
    create(:user, confirmed_phone: "111222333")
    sms = Verification::Handlers::Sms.new
    sms.phone = "111222333"

    expect(sms).not_to be_valid
  end

  describe "#verify" do
    let(:user) { create(:user) }
    let(:sms) { Verification::Handlers::Sms.new }

    before do
      field = create(:verification_field, name: :phone)
      create(:verification_field_assignment, verification_field: field, handler: :sms)
    end

    it "returns error response when unique phone validation fails" do
      create(:user, confirmed_phone: "555222333")
      response = sms.verify({ phone: "555222333", user: user })

      expect(response.success?).not_to be true
      expect(response.error?).to be true
    end

    context "when all validation passes" do
      it "returns successful response" do
        response = sms.verify({ phone: "555222333", user: user })

        expect(response.success?).to be true
        expect(response.error?).not_to be true
      end

      it "updates user unconfirmed_phone" do
        expect do
          sms.verify({ phone: "555222333", user: user })
        end.to change { user.unconfirmed_phone }.from(nil).to("555222333")
      end

      it "sends a sms message to user unconfirmed_phone" do
        expect_any_instance_of(Verification::Handlers::Sms).to receive(:send_sms)

        sms.verify({ phone: "555222333", user: user })
      end
    end
  end

  describe "#confirm" do
    let(:user) { create(:user, sms_confirmation_code: "ABCD") }
    let(:sms) { Verification::Handlers::Sms.new }

    before do
      Setting["custom_verification_process.sms"] = true
      field = create(:verification_field, name: :phone)
      create(:verification_field_assignment, verification_field: field, handler: :sms)
    end

    it "Returns error response when confirmation code provided by user
        does not matches the one send through SMS" do
      response = sms.confirm({ sms_confirmation_code: "ABCE", user: user })

      expect(response.success?).not_to be true
      expect(response.error?).to be true
    end

    it "Returns successful response when confirmation code provided by user
        matches the one send through SMS " do
      response = sms.confirm({ sms_confirmation_code: "ABCD", user: user })

      expect(response.success?).to be true
      expect(response.error?).not_to be true
    end
  end
end
