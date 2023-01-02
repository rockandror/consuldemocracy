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
end
