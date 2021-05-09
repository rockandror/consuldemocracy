require "rails_helper"

describe WelcomeController do

    describe "agend_admin" do
        it "init page agend admin" do
          get :agend_admin
    
          
          expect(response.status).to eq(200)
        end
    end

    describe "eventos" do
        it "init page agend admin" do
          get :eventos
    
          
          expect(response.status).to eq(200)
        end
    end

    describe "encuentrosconexpertos" do
        it "init page agend admin" do
          get :encuentrosconexpertos
    
          
          expect(response.status).to eq(200)
        end
    end

end