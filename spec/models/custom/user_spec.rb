require "rails_helper"

describe User do
  describe "#build_username" do
    it "uses name and last name" do
      user = User.new(first_name: "Johann", last_name: "Johannson")

      expect(user.build_username).to eq "johann_johannson"
    end

    it "uses the first name when no last name is provided" do
      user = User.new(first_name: "", last_name: "Johannson")

      expect(user.build_username).to eq "johannson"
    end

    it "uses the last name when no first name is provided" do
      user = User.new(first_name: "Johann", last_name: "")

      expect(user.build_username).to eq "johann"
    end

    context "a user with the same username exists" do
      let!(:existing_user) { create(:user, username: "johann_johannson") }

      it "adds an integer suffix to the username" do
        user = User.new(first_name: "Johann", last_name: "Johannson")

        expect(user.build_username).to eq "johann_johannson2"
      end

      it "adds as many numbers as necessary when several users exist" do
        3.times { |n| create(:user, username: "johann_johannson#{n + 2}") }
        user = User.new(first_name: "Johann", last_name: "Johannson")

        expect(user.build_username).to eq "johann_johannson5"
      end

      it "generates the same username for the existing user" do
        existing_user.first_name = "Johann"
        existing_user.last_name = "Johannson"

        expect(existing_user.build_username).to eq "johann_johannson"
      end

      it "generates an incremental username for users who registered with oauth with the same username" do
        user = create(:user,
                      first_name: "Johann",
                      last_name: "Johannson",
                      username: "johann_johannson",
                      registering_with_oauth: true)

        expect(user.build_username).to eq "johann_johannson2"
      end
    end
  end
end
