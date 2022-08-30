module Questionable
  extend ActiveSupport::Concern

  included do
    has_one :votation_type, as: :questionable, dependent: :destroy
    accepts_nested_attributes_for :votation_type
  end
end
