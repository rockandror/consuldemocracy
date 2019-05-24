require "rails_helper"

describe Census::Local::Importation do

  let(:base_files_path) { %w[spec fixtures files census local importation] }
  let(:importation) { build(:census_local_importation) }

  describe "Validations" do
    it "is valid" do
      expect(importation).to be_valid
    end

    it "is not valid without a file to import" do
      importation.file = nil

      expect(importation).not_to be_valid
    end

    context "When file extension" do
      it "is wrong it should not be valid" do
        file = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.gif")
        importation = build(:census_local_importation, file: file)

        expect(importation).not_to be_valid
      end

      it "is csv it should be valid" do
        path = base_files_path << "valid.csv"
        file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
        importation = build(:census_local_importation, file: file)

        expect(importation).to be_valid
      end
    end

    context "When file headers" do
      it "are all missing it should not be valid" do
        path = base_files_path << "valid-without-headers.csv"
        file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
        importation = build(:census_local_importation, file: file)

        expect(importation).not_to be_valid
      end
    end
  end

  context "#save" do
    it "Create valid local census records with provided values" do
      importation.save
      census_local = Census::Local.find_by(document_number: "X11556678")

      expect(census_local).not_to be_nil
      expect(census_local.document_type).to eq("NIE")
      expect(census_local.document_number).to eq("X11556678")
      expect(census_local.date_of_birth).to eq(Date.parse("07/08/1987"))
      expect(census_local.postal_code).to eq("7008")
    end

    it "Add successfully created local census records to created_records array" do
      importation.save

      valid_document_numbers = ["44556678T", "33556678T", "22556678T", "X11556678"]
      expect(importation.created_records.collect(&:document_number)).to eq(valid_document_numbers)
    end

    it "Add invalid local census records to invalid_records array" do
      path = base_files_path << "invalid.csv"
      file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
      importation.file = file

      importation.save

      invalid_records_document_types = [nil, "DNI", "Passport", "NIE"]
      invalid_records_document_numbers = ["44556678T", nil, "22556678T", "X11556678"]
      invalid_records_date_of_births = [Date.parse("07/08/1984"), Date.parse("07/08/1985"), nil,
        Date.parse("07/08/1987")]
      invalid_records_postal_codes = ["7008", "7009", "7010", nil]
      expect(importation.invalid_records.collect(&:document_type))
        .to eq(invalid_records_document_types)
      expect(importation.invalid_records.collect(&:document_number))
        .to eq(invalid_records_document_numbers)
      expect(importation.invalid_records.collect(&:date_of_birth))
        .to eq(invalid_records_date_of_births)
      expect(importation.invalid_records.collect(&:postal_code))
      .to eq(invalid_records_postal_codes)
    end
  end
end
