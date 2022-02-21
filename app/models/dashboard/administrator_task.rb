class Dashboard::AdministratorTask < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :user

  audited on: [:create, :update, :destroy]

  validates :source, presence: true

  default_scope { order(created_at: :asc) }

  scope :pending, -> { where(executed_at: nil) }
  scope :done, -> { where.not(executed_at: nil) }
end
