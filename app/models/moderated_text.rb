class ModeratedText < ApplicationRecord
  default_scope { order("text ASC") }

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :comments, through: :moderated_contents, as: :moderable
  has_many :moderated_contents, dependent: :destroy, as: :moderable

  validates :text, presence: true, uniqueness: true
end
