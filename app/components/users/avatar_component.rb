class Users::AvatarComponent < ApplicationComponent
  attr_reader :size, :user, :css

  delegate :avatar_image, to: :helpers

  def initialize(user:, size:, css: nil)
    @user = user
    @size = size
    @css = css
  end

  def seed
    user&.id
  end

  def avatar_enabled?
    feature?(:allow_images) && user&.avatar&.attached? && user&.avatar&.persisted?
  end
end
