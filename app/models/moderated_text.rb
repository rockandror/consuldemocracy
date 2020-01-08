class ModeratedText < ApplicationRecord

  validates :text, presence: true, uniqueness: true

end
