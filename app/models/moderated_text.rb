class ModeratedText < ApplicationRecord
  default_scope { order("text ASC") }

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  validates :text, presence: true, uniqueness: true

end
