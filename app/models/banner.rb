class Banner < ApplicationRecord
  include Imageable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title,presence: false
  validates_translation :description, presence: false

  validates :post_started_at, presence: true
  validates :post_ended_at, presence: true

  has_many :sections
  has_many :web_sections, through: :sections

  scope :with_active,   -> { where("post_started_at <= ?", Time.current).where("post_ended_at >= ?", Time.current) }

  scope :with_inactive, -> { where("post_started_at > ? or post_ended_at < ?", Time.current, Time.current) }

  scope :in_section, ->(section_name) { joins(:web_sections, :sections).where("web_sections.name ilike ?", section_name) }

  scope :subsection, ->(subsection) { where(subsection: subsection) }
end
