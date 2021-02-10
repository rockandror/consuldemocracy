class Moderator < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, to: :user,:allow_nil => true

  validates :user_id, presence: true, uniqueness: true
end
