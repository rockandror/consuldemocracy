require "csv"

class Verification::Residents::Import
  include ActiveModel::Model

  ALLOWED_FILE_EXTENSIONS = %w[csv].freeze

  attr_accessor :file, :created_records, :invalid_records

  validates :file, presence: true
  validate :file_extension, if: -> { @file.present? }

  def initialize(attributes = {})
    if attributes.present?
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
    @created_records = []
    @invalid_records = []
  end

  def save
    return false if invalid?

    CSV.open(file.path, headers: true).each do |row|
      next if empty_row?(row)

      process_row row
    end
    true
  end

  private

    def process_row(row)
      resident = build_resident_from(row)

      if resident.invalid?
        invalid_records << resident
      else
        resident.save
        created_records << resident
      end
    end

    def build_resident_from(row)
      resident = Verification::Resident.new
      attributes = row.to_hash.slice(*fetch_file_headers)
      resident.data = attributes
      resident
    end

    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    def file_extension
      return if valid_extension?

      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    def fetch_file_headers
      CSV.open(file.path, &:readline)
    end

    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include? extension
    end

    def extension
      File.extname(file.original_filename).delete(".")
    end
end
