module Questionable
  extend ActiveSupport::Concern

  included do
    has_one :votation_type, as: :questionable, dependent: :destroy
  end
end
