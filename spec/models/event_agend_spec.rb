require "rails_helper"

describe EventAgend do

  let(:event_agend) { build(:event_agend) }

  it "is valid" do
    expect(event_agend).to be_valid
  end

  it "is not valid without a date_at" do
    event_agend.date_at = nil
    expect(event_agend).not_to be_valid
  end


  it "is not valid without a hour_at" do
    event_agend.hour_at = nil
    expect(event_agend).not_to be_valid
  end

  it "is not valid with hour_to great to hour_at" do
    event_agend.hour_at = "10:00"
    event_agend.hour_to = "09:00"
    expect(event_agend).not_to be_valid
  end

  it "get hour data" do   
    event_agend.hour_at = "08:00"
    expect(event_agend.hour).not_to eq(nil)
    event_agend.hour_to = "09:00"
    expect(event_agend.hour).not_to eq(nil)
  end

end
