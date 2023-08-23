require_dependency Rails.root.join("app", "models", "document").to_s

class Document < ApplicationRecord
  before_save :remove_metadata

  private

    def remove_metadata
      return unless attachment.attached?

      attachment_path = ActiveStorage::Blob.service.path_for(attachment.key)
      Exiftool.new(attachment_path, "-all:all=")
    rescue Exiftool::ExiftoolNotInstalled, Exiftool::NoSuchFile
      nil
    end
end
