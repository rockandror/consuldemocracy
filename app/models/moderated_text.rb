class ModeratedText < ApplicationRecord
  default_scope { order("text ASC") }

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :comments, through: :moderated_contents
  has_many :moderated_contents, dependent: :destroy, foreign_key: "moderated_text_id"

  scope :get_word_ids, ->(words) { where(text: words).pluck(:id) }

  validates :text, presence: true, uniqueness: true
end
