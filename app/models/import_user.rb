require "csv"
require 'base_importer'

class ImportUser < BaseImporter
  include ActiveModel::Model

  ATTRIBUTES = %w[username email document_number].freeze

  ALLOWED_FILE_EXTENSIONS = %w[.csv].freeze

  attr_accessor :file

  validates :file, presence: true
  validate :file_extension, if: -> { @file.present? }
  validate :valid_headers?, if: -> { @file.present? && valid_extension? }

  def initialize(attrs = {})
    super
    if attrs.present?
      attrs.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
  end

  def save
    return false if invalid?
    @path_to_file = file.path
    import!
    true
  end

  def save!
    validate! && save
  end

  private


    def import!
      super
      each_row do |row|
        user = build_user(row)
      end
    end

    def build_user(row)
      User.new(username: row[:username], email:  row[:email], document_number:  row[:document_number])
    end

    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    def file_extension
      return if valid_extension?
      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include?(File.extname(file.original_filename))
    end

    def valid_headers?
      headers = CSV.open(file.path, &:readline)

      # return if headers.all? { |header| ATTRIBUTES.include?(header) } &&
      #           ATTRIBUTES.all? { |attr| headers.include?(attr) }

      # errors.add :file, :headers, required_headers: ATTRIBUTES.join(", ")
    end
end
