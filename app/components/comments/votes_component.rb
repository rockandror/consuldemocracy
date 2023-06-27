class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment
  delegate :can?, :current_user, to: :helpers

  def initialize(comment)
    @comment = comment
  end

  def pressed?(value)
    comment.is_pressed?(current_user, value)
  end
end
