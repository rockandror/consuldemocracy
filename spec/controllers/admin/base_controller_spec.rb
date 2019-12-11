require "rails_helper"
describe Admin::BaseController do
  
    it "double_verified" do
        user = User.create!(
              username:               "admin",
              email:                  "admin@madrid.es",
              password:               "12345678",
              password_confirmation:  "12345678",
              confirmed_at:           Time.current,
              terms_of_service:       "1",
              gender:                 ["Male", "Female"].sample,
              date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
              public_activity:        (rand(1..100) > 30)
            )

  
        user.create_administrator
        user.update(residence_verified_at: Time.current,
                    confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                    verified_at: Time.current, document_number: '73954491S')
        user.create_poll_officer
        sign_in(user)
        expect(response.status).to eq(200)
    end
end