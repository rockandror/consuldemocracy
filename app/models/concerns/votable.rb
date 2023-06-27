module Votable
  extend ActiveSupport::Concern

  def vote(user, vote_value)
    if undo_vote?(user, vote_value)
      undo_vote(user, vote_value)
    else
      vote_by(voter: user, vote: vote_value)
    end
  end

  def undo_vote?(user, vote_value)
    old_vote_value = user.voted_as_when_voted_for(self)
    new_vote_value = parse_vote_value(vote_value)

    old_vote_value == new_vote_value
  end

  def undo_vote(user, vote_value)
    parse_vote_value(vote_value) ? unliked_by(user) : undisliked_by(user)
  end

  def is_pressed?(user, value)
    case user&.voted_as_when_voted_for(self)
    when true
      value == "yes"
    when false
      value == "no"
    else
      false
    end
  end

  private

    def parse_vote_value(vote_value)
      vote_value == "yes"
    end
end
