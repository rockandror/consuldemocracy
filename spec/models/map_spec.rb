require 'rails_helper'

describe Map, type: :model do
  let(:map) { build(:map) }

  context "save" do

    it "should update attributes" do
      map = Map.find
      map.latitude = 25.0
      map.longitude = 3.0
      map.zoom = 12
      map.save

      expect(map.latitude).to eq 25.0
      expect(map.longitude).to eq 3.0
      expect(map.zoom).to eq 12
    end

    it "should update attributes and return true" do
      expect(map.save).to be true
    end

  end

  context "find" do

    before { map.save }

    it "should return new city map object with all attributes filled with map settings values" do
      map = Map.find

      expect(map.latitude).to eq(51.48)
      expect(map.longitude).to eq(0)
      expect(map.zoom).to eq(10)
    end

  end

end
