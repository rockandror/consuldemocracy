require "rails_helper"

describe User do
  describe "#password_regex" do
    it "is not valid with just lowercase characters" do
      user = build(:user, password: "just_lowercase")

      expect(user).to be_invalid
      expect(user.errors.messages[:password]).to include("must contain at least one digit")
      expect(user.errors.messages[:password]).to include("must contain at least one upper-case letter")
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

  describe "#update_roles" do
    describe "admin role" do
      it "creates new administrators" do
        user = create(:user)

        user.update_roles(["cn=gaut_admin_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_administrator
      end

      it "keeps existing administrators when present" do
        user = create(:administrator).user

        user.update_roles(["cn=gaut_admin_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_administrator
      end

      it "removes existing administrators when absent" do
        user = create(:administrator).user

        user.update_roles([])

        expect(user.reload).not_to be_administrator
      end
    end

    describe "moderator role" do
      it "creates new moderators" do
        user = create(:user)

        user.update_roles(["cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_moderator
      end

      it "keeps existing moderators when present" do
        user = create(:moderator).user

        user.update_roles(["cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_moderator
      end

      it "removes existing moderators when absent" do
        user = create(:moderator).user

        user.update_roles([])

        expect(user.reload).not_to be_moderator
      end
    end

    describe "manager role" do
      it "creates new managers" do
        user = create(:user)

        user.update_roles(["cn=gaut_gestores_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_manager
      end

      it "keeps existing managers when present" do
        user = create(:manager).user

        user.update_roles(["cn=gaut_gestores_ecociv_consul,ou=Grupos,c=es"])

        expect(user.reload).to be_manager
      end

      it "removes existing managers when absent" do
        user = create(:manager).user

        user.update_roles([])

        expect(user.reload).not_to be_manager
      end
    end

    it "creates several roles at once" do
      user = create(:user)

      user.update_roles([
        "cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es",
        "cn=gaut_gestores_ecociv_consul,ou=Grupos,c=es"
      ])
      user.reload

      expect(user).to be_moderator
      expect(user).to be_manager
      expect(user).not_to be_administrator
    end

    it "removes several roles at once" do
      user = create(:user, administrator: create(:administrator), manager: create(:manager))

      user.update_roles([])
      user.reload

      expect(user).not_to be_administrator
      expect(user).not_to be_manager
    end

    it "removes existing roles when another role is assigned" do
      user = create(:administrator).user

      user.update_roles(["cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es"])
      user.reload

      expect(user).to be_moderator
      expect(user).not_to be_administrator
    end

    it "removes existing roles when several other roles are assigned" do
      user = create(:administrator).user

      user.update_roles([
        "cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es",
        "cn=gaut_gestores_ecociv_consul,ou=Grupos,c=es"
      ])
      user.reload

      expect(user).to be_moderator
      expect(user).to be_manager
      expect(user).not_to be_administrator
    end

    it "adds, keeps, and removes existing roles, all at the same time" do
      user = create(:user, administrator: create(:administrator), manager: create(:manager))

      user.update_roles([
        "cn=gaut_moderadores_ecociv_consul,ou=Grupos,c=es",
        "cn=gaut_gestores_ecociv_consul,ou=Grupos,c=es"
      ])
      user.reload

      expect(user).to be_moderator
      expect(user).to be_manager
      expect(user).not_to be_administrator
    end

    it "does nothing when nil is passed" do
      user = create(:administrator).user

      user.update_roles(nil)

      expect(user.reload).to be_administrator
    end
  end
end
