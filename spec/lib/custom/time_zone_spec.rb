require "rails_helper"

describe "Application time zone" do
  it "uses the Canary Islands time zone" do
    travel_to(Time.utc(2015, 7, 15, 13, 00, 00)) do
      expect(Time.current.strftime("%Y-%m-%d %H:%M:%S")).to eq "2015-07-15 14:00:00"
    end
  end
end
