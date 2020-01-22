class ModeratedContent < ApplicationRecord
  belongs_to :comment, foreign_key: "moderable_id"
  belongs_to :moderated_text, foreign_key: "moderated_text_id"
  belongs_to :moderable, polymorphic: true

  scope :confirmed, -> { where("confirmed_at IS NOT ?", nil) }
  scope :declined, -> { where("declined_at IS NOT ?", nil) }
end
