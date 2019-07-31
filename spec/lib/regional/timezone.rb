require "rails_helper"

describe Regional::Timezone do

  describe "Timezone" do

    context "#load_timezone" do

      after do
        Time.zone = "Madrid"
      end

      it "when related Setting with timezone is blank, return timezone defined in application.rb" do
        Setting["regional.time_zone.key"] = nil

        Regional::Timezone.load_timezone

        expect(Time.zone.name).to eq "Madrid"
      end

      it "when related Setting with timezone is filled, return timezone defined in Settings" do
        Setting["regional.time_zone.key"] = "Lima"

        Regional::Timezone.load_timezone

        expect(Time.zone.name).to eq "Lima"
      end

    end

  end

end
