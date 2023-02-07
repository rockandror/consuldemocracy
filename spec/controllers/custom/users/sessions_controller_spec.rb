require "rails_helper"

describe Users::SessionsController do
  describe "Activity log" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      create(:user, email: "citizen@consul.org", password: "12345678")
    end

    context "when login process is successful" do
      it "tracks the login result" do
        expect do
          post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
        end.to change(ActivityLog, :count).by(1)
        activity_log = ActivityLog.last
        expect(activity_log.activity).to eq("login")
        expect(activity_log.result).to eq("ok")
      end
    end

    context "when login process returns an error" do
      it "tracks the login error" do
        expect do
          post :create, params: { user: { login: "citizen@consul.org", password: "wrong" }}
        end.to change(ActivityLog, :count).by(1)
        activity_log = ActivityLog.last
        expect(activity_log.activity).to eq("login")
        expect(activity_log.result).to eq("error")
      end

      it "tracks the user account lock" do
        Setting["login_attempts_before_lock"] = 1
        expect do
          post :create, params: { user: { login: "citizen@consul.org", password: "wrong" }}
        end.to change(ActivityLog, :count).by(2)
        activity_log = ActivityLog.first
        expect(activity_log.activity).to eq("login")
        expect(activity_log.result).to eq("error")
        activity_log = ActivityLog.last
        expect(activity_log.activity).to eq("login")
        expect(activity_log.result).to eq("blocked")
      end
    end
  end
end
