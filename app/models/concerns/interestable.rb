module Interestable
  extend ActiveSupport::Concern

  included do
    has_many :interests, as: :interestable
    # has_many :interested_users, through: :interests
  end

  # def follow(user)
  #   Interest.create(entity: self, user: user)
  # end
  #
  # def unfollow(user)
  #   Interest.find_by(entity: self, user: user).destroy
  # end

end