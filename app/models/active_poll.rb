class ActivePoll < ApplicationRecord
  include Measurable
  audited on: [:create, :update, :destroy]

  translates :description, touch: true
  include Globalizable
end
