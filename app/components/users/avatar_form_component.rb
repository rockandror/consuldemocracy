class Users::AvatarFormComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end
end
