class DocumentUploader < Shrine

  plugin :activerecord
  plugin :logging, logger: Rails.logger
  plugin :direct_upload
  plugin :cached_attachment_data
  plugin :determine_mime_type
  plugin :validation_helpers

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

        # debugger

        validate_mime_type_inclusion documentable_class.accepted_content_types,
                                   message: I18n.t("documents.errors.messages.wrong_content_type",
                                                    content_type: document.attachment.mime_type,
                                                    accepted_content_types: ApplicationController.helpers.humanized_accepted_content_types(documentable))
      end
    end
  end

end