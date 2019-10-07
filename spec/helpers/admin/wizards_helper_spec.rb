require "rails_helper"

describe Admin::WizardsHelper do

  context "#next_step_path" do

    describe "when current step is handlers index" do

      it "return remote_census step path if census soap Setting is enabled" do
        Setting["custom_verification_process.remote_census"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return resident step path if census soap Setting is disabled and census local is enabled" do
        Setting["custom_verification_process.remote_census"] = false
        Setting["custom_verification_process.residents"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:residents))
      end

      it "return sms step path if census soap and local Settings are disabled and sms is enabled" do
        Setting["custom_verification_process.remote_census"] = false
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return finish step path if all Settings are disabled" do
        Setting["custom_verification_process.remote_census"] = false
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("handlers")).to eq(admin_wizards_verification_finish_path)
      end

    end

    describe "when current step is remote_census" do

      it "return resident step path if census local Setting is enabled" do
        Setting["custom_verification_process.residents"] = true

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_handler_field_assignments_path(:residents))
      end

      it "return sms step path if census local Setting is disabled and sms is enabled" do
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return finish step path if all Settings are disabled" do
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("remote_census")).to eq(admin_wizards_verification_finish_path)
      end

    end

    describe "when current step is resident" do

      it "return sms step path if sms Setting is enabled" do
        Setting["custom_verification_process.sms"] = true

        expect(next_step_path("residents")).to eq(admin_wizards_verification_handler_field_assignments_path(:sms))
      end

      it "return finish step path if sms Setting is disabled" do
        Setting["custom_verification_process.sms"] = false

        expect(next_step_path("residents")).to eq(admin_wizards_verification_finish_path)
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

      it "return remote_census step path if remote_census Setting is enabled" do
        Setting["custom_verification_process.remote_census"] = true

        expect(back_step_path("residents")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return handler index path if remote_census Setting is disabled" do
        Setting["custom_verification_process.remote_census"] = false

        expect(back_step_path("residents")).to eq(admin_wizards_verification_handlers_path)
      end

    end

    describe "when current step is sms" do

      it "return resident step path if residents Setting is enabled" do
        Setting["custom_verification_process.residents"] = true

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handler_field_assignments_path(:residents))
      end

      it "return remote_census step if residents Setting is disabled and remote_census is enabled" do
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.remote_census"] = true

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handler_field_assignments_path(:remote_census))
      end

      it "return handler index path if remote_census and residents Settings are disabled" do
        Setting["custom_verification_process.residents"] = false
        Setting["custom_verification_process.remote_census"] = false

        expect(back_step_path("sms")).to eq(admin_wizards_verification_handlers_path)
      end

    end

  end

end
