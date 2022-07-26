class Shared::CommentsInfoComponent < ApplicationComponent
  attr_reader :comments_count, :url, :span_class

  def initialize(comments_count, url: nil, span_class: "comments-count")
    #TODO Is posible pass resource by defautl
    @comments_count = comments_count
    @url = url
    @span_class = span_class
  end

  def comments_info
    #TODO link_to_if
    tag.span class: span_class, "area-hidden": true do
      url.present? ? link_to(text, url) : text
    end
  end

  def text
    t("shared.comments", count: comments_count)
  end
end
