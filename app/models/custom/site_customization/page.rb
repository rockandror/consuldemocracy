require_dependency Rails.root.join("app", "models", "site_customization", "page").to_s

class SiteCustomization::Page
  VALID_FILTERS = %w[all news others].freeze

  validates :news_date, presence: true, if: :is_news?

  def self.search(terms)
    results = SiteCustomization::Page.joins(:translations).locale
    if terms[:text].present?
      results = results.where("title ILIKE ? OR slug ILIKE ?", "%#{terms[:text]}%", "%#{terms[:text]}%")
    end
    if terms[:type] != "all"
      results = results.where("is_news = ?", terms[:type] == "news")
    end
    if terms[:start_date].present?
      results = results.where("site_customization_pages.created_at >= ? OR news_date >= ?", terms[:start_date], terms[:start_date])
    end
    if terms[:end_date].present?
      results = results.where("site_customization_pages.created_at <= ? OR news_date <= ?", terms[:end_date], terms[:end_date])
    end
    results
  end

  def self.quick_search(terms)
    if terms[:text] == "" && terms[:type] == nil && terms[:start_date] == "" && terms[:end_date] == ""
      SiteCustomization::Page.none
    else
      search(terms)
    end
  end

  def is_news?
    is_news
  end

  def searchable_translations_definitions
    {
      title       => "A",
      description => "C"
    }
  end

  def searchable_values
    {
      slug => "B"
    }.merge!(searchable_globalized_values)
  end
end
