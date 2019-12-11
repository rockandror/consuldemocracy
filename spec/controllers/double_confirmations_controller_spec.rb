require "rails_helper"
describe DoubleConfirmationsController do

    it "new_password_sent" do
        get :new_password_sent
        expect(response.status).to eq(302)


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
        get :new_password_sent#, {params}, {session}

        expect(response.status).to eq(302)
    end

    it "request_post_access_key" do
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
                    verified_at: Time.current, document_number: '73954491S',
                    access_key_tried: 2, access_key_generated: '12345678')
        user.create_poll_officer
        sign_in(user)
        get :request_post_access_key, params:{access_key: nil} 
        expect(response.status).to eq(302)
        get :request_post_access_key, params:{access_key: '12345'} 
        expect(response.status).to eq(302)

         user.update(access_key_tried: 4)
         get :request_post_access_key, params:{access_key: '12345'} 
         expect(response.status).to eq(302)

    end
end