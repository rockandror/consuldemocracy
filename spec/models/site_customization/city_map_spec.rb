require 'rails_helper'

describe SiteCustomization::CityMap, type: :model do
  let(:city_map) { build(:city_map}

  it "should be valid" do
    expect(block).to be_valid
  end

end
