require 'rails_helper'

describe SiteCustomization::CityMap, type: :model do
  let(:city_map) { build(:city_map) }

  it "should be valid" do
    expect(city_map).to be_valid
  end

  it "should be valid without address" do
    city_map.address = nil

    expect(city_map).to_not be_valid
  end

  it "should be valid without latitude" do
    city_map.latitude = nil

    expect(city_map).to_not be_valid
  end

  it "should be valid without longitude" do
    city_map.longitude = nil

    expect(city_map).to_not be_valid
  end

  it "should be valid without zoom" do
    city_map.zoom = nil

    expect(city_map).to_not be_valid
  end

  context "save" do

    it "should return true when city_map is valid" do
      expect(city_map.save).to be true
    end

    it "should return false when city_map is invalid" do
      city_map.zoom = nil

      expect(city_map.save).to be false
    end

  end

  context "find" do

    it "should return new city map object with all map settings" do
      Setting['feature.map.address'] = "Greenwich"
      Setting['feature.map.latitude'] = 51.48
      Setting['feature.map.longitude'] = 0
      Setting['feature.map.zoom'] = 10

      expect(SiteCustomization::CityMap.find.address).to eq("Greenwich")
      expect(SiteCustomization::CityMap.find.latitude).to eq(51.48)
      expect(SiteCustomization::CityMap.find.longitude).to eq(0)
      expect(SiteCustomization::CityMap.find.zoom).to eq(10)
    end

  end

end
