shared_examples "document validations" do |documentable_factory|
  include DocumentsHelper
  include DocumentablesHelper

  context "when source is file" do

    let!(:document)               { build(:document, documentable_factory.to_sym, :file_document) }
    let!(:documentable)           { document.documentable }
    let!(:maxfilesize)            { max_file_size(documentable) }
    let!(:acceptedcontenttypes)   { accepted_content_types(documentable) }

    it "should be valid" do
      expect(document).to be_valid
    end

    it "should not be valid without a title" do
      document.title = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without an attachment" do
      document.attachment = nil

      expect(document).to_not be_valid
    end

    it "should be valid for all accepted content types" do
      acceptedcontenttypes.each do |content_type|
        extension = content_type.split("/").last
        document.attachment = File.new("spec/fixtures/files/empty.#{extension}")

        expect(document).to be_valid
      end
    end

    it "should not be valid for attachments larger than documentable max_file_size definition" do
      document.stub(:attachment_file_size).and_return(maxfilesize.megabytes + 1.byte)

      expect(document).to_not be_valid
      expect(document.errors[:attachment]).to include "must be in between 0 Bytes and #{maxfilesize} MB"
    end

    it "should not be valid without a user_id" do
      document.user_id = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without a documentable_id" do
      document.documentable_id = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without a documentable_type" do
      document.documentable_type = nil

      expect(document).to_not be_valid
    end

  end

  context "when source is link" do

    let!(:document)               { build(:document, documentable_factory.to_sym, :link_document) }

    it "should be valid" do
      expect(document).to be_valid
    end

    it "should not be valid without a title" do
      document.title = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without a user_id" do
      document.user_id = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without a documentable_id" do
      document.documentable_id = nil

      expect(document).to_not be_valid
    end

    it "should not be valid without a documentable_type" do
      document.documentable_type = nil

      expect(document).to_not be_valid
    end

  end

end