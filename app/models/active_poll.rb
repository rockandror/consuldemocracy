class ActivePoll < ActiveRecord::Base
  include Measurable

  translates :description, touch: true
  include Globalizable
  validates_translation :description, presence: true
end
