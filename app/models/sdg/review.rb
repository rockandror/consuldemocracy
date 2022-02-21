class SDG::Review < ApplicationRecord
  validates :relatable_id, uniqueness: { scope: [:relatable_type] }

  belongs_to :relatable, polymorphic: true, optional: false

  audited on: [:create, :update, :destroy]
end
