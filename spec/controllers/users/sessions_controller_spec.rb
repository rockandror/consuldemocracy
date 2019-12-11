require "rails_helper"
describe Users::SessionsController do


  it "not required_new_password? with less than 3 months" do
    user = User.create(access_key_generated_at: '23/09/2019')
    expect(user.required_new_password?).to eq false
  end

  it "required_new_password? without access_key_generated_at" do
    user = User.create(access_key_generated_at: nil)
    expect(user.required_new_password?).to eq true
  end
end