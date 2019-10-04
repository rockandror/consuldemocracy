require "rails_helper"

describe Admin::WizardsHelper do

  context "#next_step_path" do

    describe "when current step is handlers index" do

      it "return remote_census step path if census soap Setting is enabled" do
        Setting["custom_verification_process.census_soap"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return resident step path if census soap Setting is disabled and census local is enabled" do
        Setting["custom_verification_process.census_soap"] = false
        Setting["custom_verification_process.census_local"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:resident))
      end

      it "return sms step path if census soap and local Settings are disabled and sms is enabled" do
        Setting["custom_verification_process.census_soap"] = false
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return handlers step path if all Settings are disabled" do
        Setting["custom_verification_process.census_soap"] = false
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handlers_path)
      end

    end

    describe "when current step is remote_census" do

      it "return resident step path if census local Setting is enabled" do
        Setting["custom_verification_process.census_local"] = true

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_handler_field_assignments_path(:resident))
      end

      it "return sms step path if census local Setting is disabled and sms is enabled" do
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return finish step path if all Settings are disabled" do
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_finish_path)
      end

    end

    describe "when current step is resident" do

      it "return sms step path if sms Setting is enabled" do
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("resident")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return finish step path if sms Setting is disabled" do
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("resident")).to eq(admin_wizards_verification_finish_path)
      end

    end

    describe "when current step is sms" do

      it "return finish_path" do
        expect(next_step_path("sms")).to eq(admin_wizards_verification_finish_path)
      end

    end

  end

  context "#back_step_path" do

    describe "when current step is remote_census" do

      it "return handlers index path" do
        expect(back_step_path("remote_census")).to eq(admin_wizards_verification_handlers_path)
      end

    end

    describe "when current step is resident" do

      it "return remote_census step path if census_soap Setting is enabled" do
        Setting["custom_verification_process.census_soap"] = true

        expect(back_step_path("resident")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return handler index path if census_soap Setting is disabled" do
        Setting["custom_verification_process.census_soap"] = false

        expect(back_step_path("resident")).to eq(admin_wizards_verification_handlers_path)
      end

    end

    describe "when current step is sms" do

      it "return resident step path if census_local Setting is enabled" do
        Setting["custom_verification_process.census_local"] = true

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handler_field_assignments_path(:resident))
      end

      it "return remote_census step if census_local Setting is disabled and census_soap is enabled" do
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.census_soap"] = true

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return handler index path if census_soap and census_local Settings are disabled" do
        Setting["custom_verification_process.census_local"] = false
        Setting["custom_verification_process.census_soap"] = false

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handlers_path)
      end

    end

  end

end
