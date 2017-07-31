class DocumentUploader < Shrine

  plugin :activerecord
  plugin :logging, logger: Rails.logger
  plugin :cached_attachment_data
  plugin :determine_mime_type
  plugin :validation_helpers

  plugin :direct_upload, allowed_storages: [:cache, :store], presign_options: ->(request) do
    filename = request.params["filename"]
    content_type = Rack::Mime.mime_type(File.extname(filename))

    {
      content_length_range: 0..documentable_class.max_file_size,   # limit filesize to 10MB
      content_disposition: "attachment; filename=\"#{filename}\"", # download with original filename
      content_type:        content_type,                           # set correct content type
    }
  end

  Attacher.validate do
    document = self.record

    if document.present?
      documentable        = document.documentable
      documentable_class  = documentable.class

      if documentable.present?
        validate_max_size documentable_class.max_file_size,
                          message: I18n.t("documents.errors.messages.in_between",
                                           min: "0 Bytes",
                                           max: "#{ApplicationController.helpers.max_file_size(documentable)} MB")

        validate_mime_type_inclusion documentable_class.accepted_content_types,
                                   message: I18n.t("documents.errors.messages.wrong_content_type",
                                                    content_type: document.attachment.mime_type,
                                                    accepted_content_types: ApplicationController.helpers.humanized_accepted_content_types(documentable))
      end
    end
  end

end