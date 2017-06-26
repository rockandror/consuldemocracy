class Interest < ActiveRecord::Base
  belongs_to :user
  #TODO Rock&RoR: Check touch usage on cache system
  belongs_to :interestable, polymorphic: true, counter_cache: true, touch: true

  scope(:by_user_and_interestable, lambda do |user, interestable|
    where(user_id: user.id,
          interestable_type: interestable.class.to_s,
          interestable_id: interestable.id)
  end)

  def self.follow(user, interestable)
    return false if interested?(user, interestable)
    create(user: user, interestable: interestable)
  end

  def self.unfollow(user, interestable)
    interests = by_user_and_interestable(user, interestable)
    return false if interests.empty?
    interests.destroy_all
  end

  def self.interested?(user, interestable)
    return false unless user
    !! by_user_and_interestable(user, interestable).try(:first)
  end

end