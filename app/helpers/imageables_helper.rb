module ImageablesHelper

  def imageable_class(imageable)
    imageable.class.name.parameterize('_')
  end

  def imageable_max_file_size
    image_bytes_to_mega(Image::MAX_IMAGE_SIZE)
  end

  def imageable_accepted_content_types
    Image::ACCEPTED_CONTENT_TYPE
  end

  def imageable_accepted_content_types_extensions
    Image::ACCEPTED_CONTENT_TYPE
                .collect{ |content_type| ".#{content_type.split("/").last}" }
                .join(",")
  end

  def imageable_humanized_accepted_content_types
    Image::ACCEPTED_CONTENT_TYPE
                .collect{ |content_type| content_type.split("/").last }
                .join(", ")
  end

  def imageables_note(imageable)
    t "images.form.note", accepted_content_types: imageable_humanized_accepted_content_types,
                          max_file_size: imageable_max_file_size
  end

end