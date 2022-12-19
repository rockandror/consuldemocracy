require "rails_helper"
require "cancan/matchers"

describe Abilities::TenantAdministrator do
  subject(:ability) { Ability.new(user) }

  let(:user) { administrator.user }
  let(:administrator) { create(:administrator) }

  describe "multitenancy_management_mode" do
    before { allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true) }

    context "with multitenancy enabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(true) }

      it { should be_able_to :create, Tenant }
      it { should be_able_to :read, Tenant }
      it { should be_able_to :update, Tenant }
      it { should_not be_able_to :destroy, Tenant }

      context "administrators from other tenants" do
        before do
          insert(:tenant, schema: "subsidiary")
          allow(Tenant).to receive(:current_schema).and_return("subsidiary")
        end

        it { should_not be_able_to :create, Tenant }
        it { should_not be_able_to :read, Tenant }
        it { should_not be_able_to :update, Tenant }
        it { should_not be_able_to :destroy, Tenant }
      end
    end

    context "with multitenancy disabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

      it { should_not be_able_to :create, Tenant }
      it { should_not be_able_to :read, Tenant }
      it { should_not be_able_to :update, Tenant }
      it { should_not be_able_to :destroy, Tenant }
    end
  end
end
