module EmbedVideosHelper
  def embedded_video_code(resource)
    link = resource.video_url
    title = t("proposals.show.embed_video_title", proposal: resource.title)
    if link =~ /vimeo.*/
      server = "Vimeo"
    elsif link =~ /youtu*.*/
      server = "YouTube"
    end

    if server == "Vimeo"
      reg_exp = resource.class::VIMEO_REGEX
      src = "https://player.vimeo.com/video/"
    elsif server == "YouTube"
      reg_exp = resource.class::YOUTUBE_REGEX
      src = "https://www.youtube.com/embed/"
    end

    if reg_exp
      match = link.match(reg_exp)
    end

    if match && match[2]
      '<iframe src="' + src + match[2] + '" style="border:0;" allowfullscreen title="' + title + '"></iframe>'
    else
      ""
    end
  end
end
