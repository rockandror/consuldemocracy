class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats executions]

  belongs_to :process, polymorphic: true
end
