require "rails_helper"

describe MapLocationsHelper do

  describe "#prepare_map_settings" do

    it "returns tiles provider values from Secrets when related settings do not exists" do
      options = prepare_map_settings(MapLocation.new, false, "budgets", nil)

      expect(options[:map_tiles_provider]).to eq "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      expect(options[:map_tiles_provider_attribution]).to eq "&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors"
    end

    it "returns tiles provider values from Settings when related settings are definded" do
      Setting["map.tiles_provider"] = "example_map_tiles_provider"
      Setting["map.tiles_provider_attribution"] = "example_map_tiles_provider_attribution"
      options = prepare_map_settings(MapLocation.new, false, "budgets", nil)

      expect(options[:map_tiles_provider]).to eq "example_map_tiles_provider"
      expect(options[:map_tiles_provider_attribution]).to eq "example_map_tiles_provider_attribution"
    end

  end

end
