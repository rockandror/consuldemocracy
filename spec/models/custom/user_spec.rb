require "rails_helper"

describe User do
  describe "#password_regex" do
    it "is not valid with just lowercase characters" do
      user = build(:user, password: "just_lowercase")

      expect(user).to be_invalid
      expect(user.errors.messages[:password]).to include("must contain big, small letters and digits")
    end

    it "is not valid with just lowercase and uppercase" do
      user = build(:user, password: "lowercase_UPPERCASE")

      expect(user).to be_invalid
    end

    it "is not valid with just lowercase and digits" do
      user = build(:user, password: "lowercase1234")

      expect(user).to be_invalid
    end

    it "is not valid with just uppercase and digits" do
      user = build(:user, password: "UPPERCASE1234")

      expect(user).to be_invalid
    end

    it "is valid with lowercase, uppercase and digits" do
      user = build(:user, password: "lowerUPPER1234")

      expect(user).to be_valid
    end
  end
end
