module Galleryable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :imageable, dependent: :destroy
    accepts_nested_attributes_for :images, allow_destroy: true, update_only: true

    def image_url(style)
      #Rails.configuration.relative_url_root + image.attachment.url(style) if image && image.attachment.exists?
      image.attachment.url(style) if image && image.attachment.exists?
    end
  end
end
