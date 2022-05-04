class SiteCustomization::Page < ApplicationRecord
  VALID_STATUSES = %w[draft published].freeze
  include Cardable
  translates :title,       touch: true
  translates :subtitle,    touch: true
  translates :content,     touch: true
  include Globalizable

  audited on: [:create, :update, :destroy]

  validates_translation :title, presence: true
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z\-_]*\Z/, message: :slug_format }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :news_date, presence: true, if: :is_news?

  scope :published, -> { where(status: "published").sort_desc }
  scope :sort_asc, -> { order("id ASC") }
  scope :sort_desc, -> { order("id DESC") }
  scope :with_more_info_flag, -> { where(status: "published", more_info_flag: true).sort_asc }
  scope :with_same_locale, -> { joins(:translations).locale }
  scope :locale, -> { where("site_customization_page_translations.locale": I18n.locale) }

  def self.search(terms)
    results = SiteCustomization::Page.joins(:translations).locale
    if terms[:text] != ""
      results = results.where("title ILIKE ? OR slug ILIKE ?", "%#{terms[:text]}%", "%#{terms[:text]}%")
    end
    if terms[:type] != 'Todos'
      results = results.where("is_news = ?", terms[:type] == "Noticias")
    end
    if terms[:start_date] != ''
      results = results.where("site_customization_pages.created_at >= ? OR news_date >= ?", terms[:start_date], terms[:start_date])
    end
    if terms[:end_date] != ''
      results = results.where("site_customization_pages.created_at <= ? OR news_date <= ?", terms[:end_date], terms[:end_date])
    end
    results
  end

  def self.quick_search(terms)
    if terms[:text] == "" && terms[:type] == nil && terms[:start_date] == '' && terms[:end_date] == ''
      SiteCustomization::Page.none
    else
      search(terms)
    end
  end

  def url
    "/#{slug}"
  end

  def is_news?
    is_news
  end

  def searchable_translations_definitions
    { title       => "A",
      description => "C"
    }
  end

  def searchable_values
    {
      slug       => "B",
    }.merge!(searchable_globalized_values)
  end

end
