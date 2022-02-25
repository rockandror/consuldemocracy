class SiteCustomization::Image < ActiveRecord::Base
  VALID_IMAGES = {
    "logo_header" => [211, 70],
    "logo_canarias_government" => [150, 70],
    "logo_european_union" => [83, 70],
    "gobcan-azul-260x80" => [260, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "budget_execution_no_image" => [800, 600],
    "map" => [420, 500]
  }

  has_attached_file :image,
                    url: ":relative_url_root#{Paperclip::Attachment.default_options[:url]}",
                    path: ":rails_root/public#{Paperclip::Attachment.default_options[:url]}"

  validates :name, presence: true, uniqueness: true, inclusion: { in: VALID_IMAGES.keys }
  validates_attachment_content_type :image, content_type: ["image/png", "image/jpeg"]
  validate :check_image

  def self.all_images
    VALID_IMAGES.keys.map do |image_name|
      find_by(name: image_name) || create!(name: image_name.to_s)
    end
  end

  def self.image_path_for(filename)
    image_name = filename.split(".").first

    imageable = find_by(name: image_name)
    imageable.present? && imageable.image.exists? ? imageable.image.url : nil
  end

  def required_width
    VALID_IMAGES[name].try(:first)
  end

  def required_height
    VALID_IMAGES[name].try(:second)
  end

  private

    def check_image
      return unless image?

      dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)

      errors.add(:image, :image_width, required_width: required_width) unless dimensions.width == required_width
      errors.add(:image, :image_height, required_height: required_height) unless dimensions.height == required_height
    end

end
