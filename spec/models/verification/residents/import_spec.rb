require "rails_helper"

describe Verification::Residents::Import do
  let(:base_files_path) { %w[spec fixtures files verification residents import] }
  let(:import) { build(:verification_residents_import) }

  describe "Validations" do
    it "is valid" do
      expect(import).to be_valid
    end

    it "is not valid without a file to import" do
      import.file = nil

      expect(import).not_to be_valid
    end

    context "When file extension" do
      it "is wrong it should not be valid" do
        file = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.gif")
        import = build(:verification_residents_import, file: file)

        expect(import).not_to be_valid
      end

      it "is csv it should be valid" do
        path = base_files_path << "valid.csv"
        file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
        import = build(:verification_residents_import, file: file)

        expect(import).to be_valid
      end
    end
  end

  context "#save" do
    it "Create valid verification resident with provided values" do
      expect { import.save }.not_to raise_error
      verification_resident = Verification::Resident.find_by_data({ document_number: "44556678T" })

      expect(verification_resident).not_to be_nil
      expect(verification_resident.data["document_type"]).to include("DNI")
      expect(verification_resident.data["document_number"]).to include("44556678T")
      expect(verification_resident.data["house_id"]).to include("000000001")
    end

    it "Add successfully created verification residents to created_records array" do
      expect { import.save }.not_to raise_error

      valid_document_numbers = ["44556678T", "33556678T", "22556678T", "X11556678"]
      expect(import.created_records.collect { |record| record.data["document_number"] }).
        to eq(valid_document_numbers)
    end

    it "Add invalid (duplicated) verification residents to invalid_records array" do
      path = base_files_path << "invalid.csv"
      file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
      import.file = file

      expect { import.save }.not_to raise_error

      invalid_records_document_types = ["DNI", "NIE"]
      invalid_records_document_numbers = ["44556678T", "X11556678"]
      invalid_records_house_ids = ["000000001", "000000004"]

      expect(import.invalid_records.collect { |record| record.data["document_type"] })
        .to eq(invalid_records_document_types)
      expect(import.invalid_records.collect { |record| record.data["document_number"] })
        .to eq(invalid_records_document_numbers)
      expect(import.invalid_records.collect { |record| record.data["house_id"] })
        .to eq(invalid_records_house_ids)
    end
  end
end
