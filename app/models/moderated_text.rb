class ModeratedText < ApplicationRecord

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  validates :text, presence: true, uniqueness: true

end
