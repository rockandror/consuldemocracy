require "rails_helper"

describe User do
  describe ".maximum_attempts" do
    it "returns 5 as default when the secrets aren't configured" do
      expect(User.maximum_attempts).to eq 5
    end

    context "when secrets are configured" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
          security: {
            lockable: { maximum_attempts: "14" }
          },
          tenants: {
            superstrict: {
              security: {
                lockable: { maximum_attempts: "1" }
              }
            }
          }
        ))
      end

      it "uses the general secrets for the main tenant" do
        expect(User.maximum_attempts).to eq 14
      end

      it "uses the tenant secrets for a tenant" do
        allow(Tenant).to receive(:current_schema).and_return("superstrict")

        expect(User.maximum_attempts).to eq 1
      end
    end
  end

  describe ".unlock_in" do
    it "returns 0.5 as default when the secrets aren't configured" do
      expect(User.unlock_in).to eq 0.5.hours
    end

    context "when secrets are configured" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
          security: {
            lockable: { unlock_in: "1" }
          },
          tenants: {
            superstrict: {
              security: {
                lockable: { unlock_in: "50" }
              }
            }
          }
        ))
      end

      it "uses the general secrets for the main tenant" do
        expect(User.unlock_in).to eq 1.hour
      end

      it "uses the tenant secrets for a tenant" do
        allow(Tenant).to receive(:current_schema).and_return("superstrict")

        expect(User.unlock_in).to eq 50.hours
      end
    end
  end
end
