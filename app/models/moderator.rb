class Moderator < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, to: :user

  audited on: [:create, :update, :destroy]

  validates :user_id, presence: true, uniqueness: true
end
