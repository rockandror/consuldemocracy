class Admin::Users::ShowComponent < ApplicationComponent
  attr_reader :user
  delegate :display_user_roles, to: :helpers

  def initialize(user)
    @user = user
  end

  def verified?(user)
    user.verified_at.present? && user.residence_verified_at.present? && user.level_two_verified_at.present?
  end
end
