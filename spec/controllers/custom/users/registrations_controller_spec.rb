require "rails_helper"

describe Users::RegistrationsController do
  describe "Activity log" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      InvisibleCaptcha.timestamp_enabled = false
    end

    after do
      InvisibleCaptcha.timestamp_enabled = true
    end

    context "when registration process is successful" do
      it "tracks the registration result" do
        user_attributes = { username: "available_username",
                            email: "user@consul.org",
                            password: "12345678",
                            password_confirmation: "12345678",
                            terms_of_service: "1" }

        expect do
          post :create, params: { user: user_attributes }
        end.to change(ActivityLog, :count).by(1)
        activity_log = ActivityLog.last
        expect(activity_log.activity).to eq("register")
        expect(activity_log.result).to eq("ok")
      end
    end

    context "when registration process returns an error" do
      it "tracks the error" do
        user_attributes = { username: "available_username",
                            email: "user@consul.org",
                            password: "12345678",
                            password_confirmation: "87654321",
                            terms_of_service: "1" }

        expect do
          post :create, params: { user: user_attributes }
        end.to change(ActivityLog, :count).by(1)
        activity_log = ActivityLog.last
        expect(activity_log.activity).to eq("register")
        expect(activity_log.result).to eq("error")
      end
    end
  end
end
