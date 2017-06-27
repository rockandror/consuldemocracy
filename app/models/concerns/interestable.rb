module Interestable
  extend ActiveSupport::Concern

  included do
    has_many :interests, as: :interestable
  end

end
