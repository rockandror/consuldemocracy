require 'rails_helper'

describe Verification::Residence do

  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "verification" do

    describe "postal code" do
      it "is valid with postal codes starting with 38 or 35" do
        residence.postal_code = "38012"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)

        residence.postal_code = "35023"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)
      end

      it "is not valid with postal codes not starting with 35 or 38" do
        residence.postal_code = "12345"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)

        residence.postal_code = "33280"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)
        expect(residence.errors[:postal_code]).to include("In order to be verified, you must be registered.")
      end
    end

  end

end
