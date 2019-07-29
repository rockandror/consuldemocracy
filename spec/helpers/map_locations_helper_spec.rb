require "rails_helper"

describe MapLocationsHelper do

  describe "#prepare_map_settings" do

    it "returns tiles provider values" do
      map_location = MapLocation.new
      options = prepare_map_settings(map_location, false, "budgets", nil)

      expect(options[:map_tiles_provider]).to eq "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      expect(options[:map_tiles_provider_attribution]).to eq "&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors"
    end

  end

end
