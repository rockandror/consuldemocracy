require "rails_helper"

describe LocalCensusRecord do
  let(:local_census_record) { build(:local_census_record) }

  context "validations" do
    it "is valid" do
      expect(local_census_record).to be_valid
    end

    it "is not valid without document_number" do
      local_census_record.document_number = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without document_type" do
      local_census_record.document_type = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without date_of_birth" do
      local_census_record.date_of_birth = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without postal_code" do
      local_census_record.postal_code = nil

      expect(local_census_record).not_to be_valid
    end

    it "sanitizes text attributes values before validation" do
      local_census_record.document_type = " DNI "
      local_census_record.document_number = " #DOCUMENT_NUMBER "
      local_census_record.postal_code = " 07007 "

      local_census_record.valid?

      expect(local_census_record.document_type).to eq "DNI"
      expect(local_census_record.document_number).to eq "#DOCUMENT_NUMBER"
      expect(local_census_record.postal_code).to eq "07007"
    end

    describe "When already exists a record" do
      it "with exact attributes values it should not be valid" do
        attributes = { document_type: "DNI", document_number: "#DOC_NUMBER",
          date_of_birth: "1980-07-07", postal_code: "00567" }
        create(:local_census_record, **attributes)
        local_census_record = LocalCensusRecord.new(**attributes)

        expect(local_census_record).not_to be_valid
        expect(local_census_record.errors[:base].any?).to be(true)
      end

      it "with same attribute values but with different text case it should not be valid" do
        upcase_attributes = { document_type: "DNI", document_number: "#DOC_NUMBER",
          date_of_birth: "1980-07-07", postal_code: "00567" }
        downcase_attributes = { document_type: "dni", document_number: "#doc_number",
          date_of_birth: "1980-07-07", postal_code: "00567" }
        create(:local_census_record, **upcase_attributes)
        local_census_record = LocalCensusRecord.new(**downcase_attributes)

        expect(local_census_record).not_to be_valid
        expect(local_census_record.errors[:base].any?).to be(true)
      end

      it "with same values but surrounded with whitespaces it should not be valid" do
        dirty_attributes = { document_type: " DNI ", document_number: " #DOC_NUMBER ",
          date_of_birth: "1980-07-07", postal_code: "00567" }
        attributes = { document_type: "DNI", document_number: "#DOC_NUMBER",
          date_of_birth: "1980-07-07", postal_code: "00567" }
        create(:local_census_record, **attributes)
        local_census_record = LocalCensusRecord.new(**dirty_attributes)

        expect(local_census_record).not_to be_valid
        expect(local_census_record.errors[:base].any?).to be(true)
      end
    end
  end

  context "scopes" do
    let!(:a_local_census_record) { create(:local_census_record, document_number: "AAAA") }
    let!(:b_local_census_record) { create(:local_census_record, document_number: "BBBB") }

    context "search" do
      it "filter document_numbers by given terms" do
        expect(LocalCensusRecord.search("A")).to include a_local_census_record
        expect(LocalCensusRecord.search("A")).not_to include b_local_census_record
      end

      it "ignores terms case" do
        expect(LocalCensusRecord.search("a")).to eq [a_local_census_record]
      end
    end
  end
end
