require "rails_helper"

describe Admin::EventAgendsController do
  let(:event_agend) { build(:event_agend) }

  before do
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

  end

  describe "index" do
      it "get index" do
        get :index
        expect(response.status).to eq(200)
      end
  end

    describe "create" do
        it "create a new event_agend" do
          post :create, params: {event_agend: event_agend.attributes}

          expect(response.status).to eq(302)
        end
    end

    describe "destroy" do
      it "delete element" do
        
        event_agend_1 = create(:event_agend)
        delete :destroy, params: { id: event_agend_1.id}
  
        
        expect(response.status).to eq(302)
      end
  end

end