class Comments::VotesComponent < ApplicationComponent
  include VotingButton
  attr_reader :comment
  delegate :can?, :current_user, to: :helpers

  def initialize(comment)
    @comment = comment
  end

  def vote_in_favor_against_path(value)
    if user_already_voted_with(comment, value)
      vote = comment.votes_for.find_by!(voter: current_user)

      comment_vote_path(comment, vote, value: value)
    else
      comment_votes_path(comment, value: value)
    end
  end
end
