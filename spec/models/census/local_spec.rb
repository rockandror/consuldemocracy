require "rails_helper"

describe Census::Local do
  let(:census_local) { build(:census_local) }

  context "validations" do
    it "is valid" do
      expect(census_local).to be_valid
    end

    it "is not valid without document_number" do
      census_local.document_number = nil

      expect(census_local).not_to be_valid
    end

    it "is not valid without document_type" do
      census_local.document_type = nil

      expect(census_local).not_to be_valid
    end

    it "is not valid without date_of_birth" do
      census_local.date_of_birth = nil

      expect(census_local).not_to be_valid
    end

    it "is not valid without postal_code" do
      census_local.postal_code = nil

      expect(census_local).not_to be_valid
    end

    it "sanitizes text attributes values before validation" do
      census_local.document_type = " DNI "
      census_local.document_number = " #DOCUMENT_NUMBER "
      census_local.postal_code = " 07007 "

      census_local.valid?

      expect(census_local.document_type).to eq "DNI"
      expect(census_local.document_number).to eq "#DOCUMENT_NUMBER"
      expect(census_local.postal_code).to eq "07007"
    end
  end

  context "scopes" do
    let!(:a_census_local) { create(:census_local, document_number: "AAAA") }
    let!(:b_census_local) { create(:census_local, document_number: "BBBB") }

    context "search" do
      it "filter document_numbers by given terms" do
        expect(described_class.search("A")).to include a_census_local
        expect(described_class.search("A")).not_to include b_census_local
      end

      it "ignores terms case" do
        expect(described_class.search("a")).to eq [a_census_local]
      end
    end
  end
end
