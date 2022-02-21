class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats].freeze

  audited on: [:create, :update, :destroy]

  belongs_to :process, polymorphic: true
end
